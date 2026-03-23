# Subagent

> 원본: [사용자 정의 subagent 만들기](https://code.claude.com/docs/ko/sub-agents)

## 기본 개념

- **Subagent**는 특정 작업을 처리하는 특화된 AI 어시스턴트이다.
- 각 subagent는 **자체 컨텍스트 윈도우**에서 실행되며, 사용자 정의 시스템 프롬프트·도구 액세스·독립적 권한을 가진다.
- Claude가 subagent의 `description`과 일치하는 작업을 만나면 자동으로 위임한다.
- **subagent는 다른 subagent를 생성할 수 없다** (중첩 불가). 단, `claude --agent`로 주 스레드로 실행되는 에이전트는 Agent 도구로 subagent를 생성할 수 있다.

### Subagent의 장점

| 장점 | 설명 |
|:--|:--|
| 컨텍스트 보존 | 탐색/구현을 주 대화에서 분리 |
| 제약 조건 적용 | 사용 가능한 도구를 제한 |
| 구성 재사용 | 사용자 수준 subagent로 프로젝트 간 재사용 |
| 동작 특화 | 특정 도메인을 위한 시스템 프롬프트 |
| 비용 제어 | Haiku 등 저렴한 모델로 작업 라우팅 |

## 내장 Subagent

| Subagent | 모델 | 도구 | 목적 |
|:--|:--|:--|:--|
| **Explore** | Haiku | 읽기 전용 | 파일 검색, 코드베이스 탐색. 철저함 수준: `quick` / `medium` / `very thorough` |
| **Plan** | 상속 | 읽기 전용 | plan mode에서 코드베이스 연구 |
| **General-purpose** | 상속 | 모든 도구 | 복잡한 다단계 작업, 코드 수정 |
| **Bash** | 상속 | - | 별도 컨텍스트에서 터미널 명령 실행 (자동 호출) |
| **statusline-setup** | Sonnet | - | `/statusline` 실행 시 상태 표시줄 구성 (자동 호출) |
| **Claude Code Guide** | Haiku | - | Claude Code 기능에 대한 질문 응답 (자동 호출) |

## 파일 구조 및 범위

Subagent는 **YAML frontmatter가 있는 Markdown 파일**로 정의한다.

### 범위별 저장 위치 (우선순위 순)

| 우선순위 | 위치 | 범위 | 생성 방법 |
|:--|:--|:--|:--|
| 1 (최고) | `--agents` CLI 플래그 | 현재 세션 | JSON 전달 |
| 2 | `.claude/agents/` | 현재 프로젝트 | 대화형 또는 수동 |
| 3 | `~/.claude/agents/` | 모든 프로젝트 | 대화형 또는 수동 |
| 4 (최저) | 플러그인의 `agents/` | 플러그인 활성화 위치 | 플러그인과 함께 설치 |

## 옵션

### Frontmatter 필드

| 필드                | 필수  | 설명                                                                     | 기본값       |
| :---------------- | :-- | :--------------------------------------------------------------------- | :-------- |
| `name`            | O   | 고유 식별자 (소문자, 하이픈)                                                      | -         |
| `description`     | O   | Claude가 위임 시기를 결정하는 설명                                                 | -         |
| `tools`           | X   | 사용 가능한 도구 목록. 생략 시 모든 도구 상속                                            | 모든 도구     |
| `disallowedTools` | X   | 거부할 도구 목록                                                              | -         |
| `model`           | X   | `sonnet` / `opus` / `haiku` / `inherit`                                | `inherit` |
| `permissionMode`  | X   | 권한 모드                                                                  | `default` |
| `maxTurns`        | X   | 최대 에이전트 턴 수                                                            | -         |
| `skills`          | X   | 시작 시 컨텍스트에 로드할 skill 목록                                                | -         |
| `mcpServers`      | X   | 사용 가능한 MCP 서버                                                          | -         |
| `hooks`           | X   | 라이프사이클 hook 정의. 도구 실행 전후 검문소 역할. stdin으로 JSON 수신, exit 0=통과, exit 2=차단 | -         |
| `memory`          | X   | 지속적 메모리 범위: `user` / `project` / `local`                               | -         |
| `background`      | X   | 항상 백그라운드로 실행 (`true`/`false`)                                          | `false`   |
| `isolation`       | X   | `worktree` 설정 시 임시 git worktree에서 실행. 변경 없으면 자동 정리                     | -         |

### 권한 모드 (permissionMode)

| 모드 | 동작 |
|:--|:--|
| `default` | 표준 권한 확인 (프롬프트) |
| `acceptEdits` | 파일 편집 자동 수락 |
| `dontAsk` | 권한 프롬프트 자동 거부 (명시적으로 허용된 도구는 계속 작동) |
| `bypassPermissions` | 모든 권한 확인 건너뛰기 (주의! 부모가 사용하면 자식이 재정의 불가) |
| `plan` | Plan mode (읽기 전용 탐색) |

### 메모리 범위 (memory)

| 범위 | 저장 위치 | 용도 |
|:--|:--|:--|
| `user` | `~/.claude/agent-memory/<name>/` | 모든 프로젝트에서 학습 기억 (권장 기본값) |
| `project` | `.claude/agent-memory/<name>/` | 프로젝트별 지식, 버전 제어 공유 가능 |
| `local` | `.claude/agent-memory-local/<name>/` | 프로젝트별이지만 버전 제어 제외 |

### Hook 이벤트 (hooks)

`tools` 필드로는 도구 전체를 허용/거부만 가능하지만, hook으로 **명령 내용까지 세밀하게 제어**할 수 있다.

**frontmatter 내부** (해당 subagent 활성 시에만 실행):

| 이벤트 | matcher 입력 | 실행 시기 |
|:--|:--|:--|
| `PreToolUse` | 도구 이름 | 도구 사용 **전** |
| `PostToolUse` | 도구 이름 | 도구 사용 **후** |
| `Stop` | (없음) | subagent 완료 시 (런타임에 `SubagentStop`으로 변환) |

**settings.json** (주 세션에서 subagent 라이프사이클에 응답):

| 이벤트 | matcher 입력 | 실행 시기 |
|:--|:--|:--|
| `SubagentStart` | 에이전트 이름 | subagent 실행 시작 시 |
| `SubagentStop` | 에이전트 이름 | subagent 완료 시 |

## 사용 예시

### 기본: subagent 파일 작성

```markdown
---
name: code-reviewer
description: Reviews code for quality and best practices
tools: Read, Glob, Grep
model: sonnet
---

You are a code reviewer. Analyze the code and provide
specific, actionable feedback on quality, security, and best practices.
```

### CLI에서 임시 subagent 정의

```bash
claude --agents '{
  "code-reviewer": {
    "description": "Expert code reviewer. Use proactively after code changes.",
    "prompt": "You are a senior code reviewer. Focus on code quality, security, and best practices.",
    "tools": ["Read", "Grep", "Glob", "Bash"],
    "model": "sonnet"
  }
}'
```

### 도구 제한: 읽기 전용 + 거부 목록

```yaml
---
name: safe-researcher
description: Research agent with restricted capabilities
tools: Read, Grep, Glob, Bash
disallowedTools: Write, Edit
---
```

### 생성 가능한 subagent 제한 (Agent 도구)

```yaml
---
name: coordinator
description: Coordinates work across specialized agents
tools: Agent(worker, researcher), Read, Bash
---
```

- `Agent(worker, researcher)` → worker, researcher만 생성 가능 (허용 목록)
- `Agent` (괄호 없음) → 모든 subagent 생성 가능
- `Agent` 생략 → subagent 생성 불가

### Skill 미리 로드

```yaml
---
name: api-developer
description: Implement API endpoints following team conventions
skills:
  - api-conventions
  - error-handling-patterns
---

Implement API endpoints. Follow the conventions and patterns from the preloaded skills.
```

### 지속적 메모리 활성화

```yaml
---
name: code-reviewer
description: Reviews code for quality and best practices
memory: user
---

You are a code reviewer. As you review code, update your agent memory with
patterns, conventions, and recurring issues you discover.
```

### Hook으로 조건부 규칙 적용 (읽기 전용 DB 쿼리)

```yaml
---
name: db-reader
description: Execute read-only database queries
tools: Bash
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "./scripts/validate-readonly-query.sh"
---
```

검증 스크립트 (`validate-readonly-query.sh`):

```bash
#!/bin/bash
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

if echo "$COMMAND" | grep -iE '\b(INSERT|UPDATE|DELETE|DROP|CREATE|ALTER|TRUNCATE)\b' > /dev/null; then
  echo "Blocked: Only SELECT queries are allowed" >&2
  exit 2  # exit 2 = 작업 차단 + 에러 메시지 반환
fi
exit 0
```

### 특정 subagent 비활성화

```json
{
  "permissions": {
    "deny": ["Agent(Explore)", "Agent(my-custom-agent)"]
  }
}
```

```bash
claude --disallowedTools "Agent(Explore)"
```

### Subagent Hook 정의

**frontmatter 내부** (해당 subagent 활성 시에만 실행):

```yaml
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "./scripts/validate-command.sh"
  PostToolUse:
    - matcher: "Edit|Write"
      hooks:
        - type: command
          command: "./scripts/run-linter.sh"
```

**settings.json** (주 세션에서 subagent 라이프사이클에 응답):

```json
{
  "hooks": {
    "SubagentStart": [
      { "matcher": "db-agent", "hooks": [{ "type": "command", "command": "./scripts/setup-db-connection.sh" }] }
    ],
    "SubagentStop": [
      { "hooks": [{ "type": "command", "command": "./scripts/cleanup-db-connection.sh" }] }
    ]
  }
}
```

### 포그라운드 vs 백그라운드

- **포그라운드**: 완료될 때까지 주 대화 차단. 권한 프롬프트가 사용자에게 전달됨.
- **백그라운드**: 동시 실행. 시작 전 필요한 권한을 미리 요청하며, 사전 승인되지 않은 작업은 자동 거부.
- `Ctrl+B`로 실행 중인 작업(subagent 포함)을 백그라운드로 이동 가능.
- `background: true` frontmatter로 항상 백그라운드 실행 설정 가능.

### Subagent 체인

다단계 워크플로우에서 subagent를 순차적으로 사용할 수 있다. 각 subagent가 작업을 완료하면 Claude가 결과를 받아 다음 subagent에 관련 컨텍스트를 전달한다.

```text
code-reviewer subagent로 성능 이슈를 찾고, optimizer subagent로 수정해줘
```

### 주 대화 vs Subagent 선택 가이드

| 상황 | 추천 |
|:--|:--|
| 빈번한 왕복/반복적 개선 필요 | 주 대화 |
| 여러 단계가 컨텍스트를 공유 | 주 대화 |
| 빠르고 대상 지정된 변경 | 주 대화 |
| 지연시간이 중요 | 주 대화 |
| 대량 출력을 생성하는 작업 | Subagent |
| 특정 도구/권한 제한 필요 | Subagent |
| 자체 포함된 작업 + 요약 반환 | Subagent |
| 주 대화 컨텍스트에서 재사용 프롬프트 | Skills |
| 이미 대화에 있는 내용에 대한 빠른 질문 | `/btw` |
