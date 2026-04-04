# .claude 디렉토리 구조

> https://code.claude.com/docs/en/claude-directory

## 기본 개념

- `.claude/` 디렉토리는 Claude Code의 모든 프로젝트별 설정, 규칙, 확장을 담는 디렉토리이다.
- **프로젝트 레벨** (`your-project/.claude/`)과 **글로벌 레벨** (`~/.claude/`)로 나뉜다.
- 대부분의 파일은 git에 커밋하여 팀과 공유하고, 일부(settings.local.json 등)는 자동으로 gitignore된다.

### 프로젝트 레벨 트리

```
your-project/
├── CLAUDE.md                       # [committed] 프로젝트 지침
├── .mcp.json                       # [committed] MCP 서버 설정
├── .worktreeinclude                # [committed] worktree 복사 대상
└── .claude/
    ├── settings.json               # [committed] 권한, hooks, 모델 등
    ├── settings.local.json         # [gitignored] 개인 설정 오버라이드
    ├── rules/                      # [committed] 토픽별 지침
    │   ├── testing.md
    │   └── api-design.md
    ├── skills/                     # [committed] 재사용 프롬프트
    │   └── security-review/
    │       ├── SKILL.md
    │       └── checklist.md
    ├── commands/                   # [committed] 단일 파일 커맨드
    │   └── fix-issue.md
    ├── output-styles/              # [committed] 팀 공유 출력 스타일
    ├── agents/                     # [committed] 서브에이전트 정의
    │   └── code-reviewer.md
    ├── agent-memory/               # [committed] 서브에이전트 메모리 (memory: project)
    │   └── <agent-name>/
    │       └── MEMORY.md
    └── agent-memory-local/         # [gitignored] 서브에이전트 메모리 (memory: local)
```

### 글로벌 레벨 트리

```
~/
├── .claude.json                    # [local] 앱 상태, UI 설정, 개인 MCP 서버
└── .claude/
    ├── CLAUDE.md                   # [local] 모든 프로젝트 공통 개인 지침
    ├── settings.json               # [local] 글로벌 기본 설정
    ├── keybindings.json            # [local] 키보드 단축키
    ├── rules/                      # [local] 모든 프로젝트 공통 규칙
    ├── skills/                     # [local] 모든 프로젝트 공통 스킬
    ├── commands/                   # [local] 모든 프로젝트 공통 커맨드
    ├── output-styles/              # [local] 개인 출력 스타일
    │   └── teaching.md
    ├── agents/                     # [local] 모든 프로젝트 공통 서브에이전트
    ├── agent-memory/               # [local] 서브에이전트 메모리 (memory: user)
    └── projects/                   # [local] 프로젝트별 자동 메모리
        └── <project>/memory/
            ├── MEMORY.md
            └── debugging.md
```

### 프로젝트 루트 파일

| 파일                 | 위치      | 공유                   | 설명                                                             |
| ------------------ | ------- | -------------------- | -------------------------------------------------------------- |
| `CLAUDE.md`        | 프로젝트 루트 | committed            | 매 세션 시작 시 로드되는 프로젝트 지침                                         |
| `CLAUDE.local.md`  | 프로젝트 루트 | local (수동 gitignore) | 이 프로젝트의 개인용 지침. CLAUDE.md와 함께 로드됨. 수동 생성 후 `.gitignore`에 추가 필요 |
| `.mcp.json`        | 프로젝트 루트 | committed            | 프로젝트 범위 MCP 서버 설정                                              |
| `.worktreeinclude` | 프로젝트 루트 | committed            | worktree 생성 시 복사할 gitignore 파일 목록                              |

### 프로젝트 .claude/ 하위 구조

| 경로                    | 공유         | 설명                                                                                                              |
| --------------------- | ---------- | --------------------------------------------------------------------------------------------------------------- |
| `settings.json`       | committed  | 권한, hooks, 모델, 환경변수 등 프로젝트 설정                                                                                   |
| `settings.local.json` | gitignored | 개인용 설정 오버라이드 (settings.json보다 우선). 첫 생성 시 `~/.config/git/ignore`에 자동 추가됨. 팀 공유를 위해 프로젝트 `.gitignore`에도 수동 추가 필요 |
| `rules/`              | committed  | 토픽별 지침 파일, `paths:` frontmatter로 조건부 로드 가능                                                                      |
| `skills/`             | committed  | 재사용 가능한 프롬프트 (`/skill-name`으로 호출)                                                                               |
| `commands/`           | committed  | 단일 파일 커맨드 (`/command-name`으로 호출). 레거시 — 새 워크플로에는 `skills/` 사용 권장                                                |
| `agents/`             | committed  | 전용 컨텍스트 윈도우를 가진 서브에이전트 정의                                                                                       |
| `agent-memory/`       | committed  | `memory: project` 서브에이전트의 영속 메모리. MEMORY.md 첫 200줄(25KB 상한)이 서브에이전트 시스템 프롬프트에 로드됨                               |
| `agent-memory-local/` | gitignored | `memory: local` 서브에이전트의 영속 메모리 (버전 관리 제외)                                                                       |
| `output-styles/`      | committed  | 팀 공유용 출력 스타일                                                                                                    |

### 글로벌 ~/.claude/ 하위 구조

| 경로                           | 설명                                  |
| ---------------------------- | ----------------------------------- |
| `~/.claude.json`             | 앱 상태, UI 설정, 개인 MCP 서버              |
| `~/.claude/CLAUDE.md`        | 모든 프로젝트에 적용되는 개인 지침                 |
| `~/.claude/settings.json`    | 모든 프로젝트의 기본 설정                      |
| `~/.claude/keybindings.json` | 키보드 단축키 커스터마이징                      |
| `~/.claude/projects/`        | 프로젝트별 자동 메모리 (Claude가 자동 관리)        |
| `~/.claude/rules/`           | 모든 프로젝트에 적용되는 개인 규칙                 |
| `~/.claude/skills/`          | 모든 프로젝트에서 사용 가능한 개인 스킬              |
| `~/.claude/commands/`        | 모든 프로젝트에서 사용 가능한 개인 커맨드             |
| `~/.claude/agents/`          | 모든 프로젝트에서 사용 가능한 개인 서브에이전트          |
| `~/.claude/agent-memory/`    | `memory: user` 서브에이전트의 크로스 프로젝트 메모리 |
| `~/.claude/output-styles/`   | 개인 출력 스타일                           |

## 옵션

### CLAUDE.md

| 옵션 | 설명 | 기본값 |
|------|------|--------|
| 위치 | 프로젝트 루트 또는 `.claude/CLAUDE.md` | 프로젝트 루트 |
| 로드 시점 | 매 세션 시작 | 항상 |
| 권장 크기 | 200줄 이하 | - |

### settings.json

| 키                   | 설명             | 예시                        |
| ------------------- | -------------- | ------------------------- |
| `permissions.allow` | 자동 허용할 도구/명령   | `["Bash(npm test *)"]`    |
| `permissions.deny`  | 차단할 도구/명령      | `["Bash(rm -rf *)"]`      |
| `hooks`             | 이벤트별 스크립트 실행   | PostToolUse, PreToolUse 등 |
| `model`             | 기본 모델 지정       | -                         |
| `env`               | 환경 변수 설정       | -                         |
| `outputStyle`       | 출력 스타일 선택      | -                         |
| `statusLine`        | 하단 상태 줄 커스터마이징 | -                         |

### rules/ frontmatter

| 필드 | 설명 | 기본값 |
|------|------|--------|
| `paths` | 규칙이 적용될 파일 glob 패턴 목록 | 없음 (세션 시작 시 항상 로드) |

### skills/ SKILL.md frontmatter

| 필드 | 설명 | 기본값 |
|------|------|--------|
| `description` | Claude가 자동 호출 시 매칭에 사용 | - |
| `disable-model-invocation` | `true`면 사용자만 호출 가능 | `false` |
| `user-invocable` | `false`면 `/` 메뉴에서 숨김 | `true` |
| `argument-hint` | 인자 힌트 표시 | - |

### agents/ frontmatter

| 필드 | 설명 | 기본값 |
|------|------|--------|
| `name` | 에이전트 이름 | - |
| `description` | 자동 위임 시 매칭에 사용 | - |
| `tools` | 사용 가능한 도구 제한 | 모든 도구 |
| `memory` | 영속 메모리 저장 위치: `project` → `.claude/agent-memory/` (committed), `local` → `.claude/agent-memory-local/` (gitignored), `user` → `~/.claude/agent-memory/` (크로스 프로젝트) | 없음 |

### output-styles/ frontmatter

| 필드 | 설명 | 기본값 |
|------|------|--------|
| `description` | 스타일 설명 | - |
| `keep-coding-instructions` | `true`면 기본 코딩 지침 유지. 기본값 `false`일 경우 내장 소프트웨어 엔지니어링 지침이 시스템 프롬프트에서 제거됨 | `false` |

## 사용 예시

### CLAUDE.md 기본 예시

```markdown
# Project conventions

## Commands
- Build: `npm run build`
- Test: `npm test`
- Lint: `npm run lint`

## Stack
- TypeScript with strict mode
- React 19, functional components only

## Rules
- Named exports, never default exports
- Tests live next to source: `foo.ts` -> `foo.test.ts`
- All API routes return `{ data, error }` shape
```

### settings.json — 권한 및 hooks 설정

```json
{
  "permissions": {
    "allow": [
      "Bash(npm test *)",
      "Bash(npm run *)"
    ],
    "deny": [
      "Bash(rm -rf *)"
    ]
  },
  "hooks": {
    "PostToolUse": [{
      "matcher": "Edit|Write",
      "hooks": [{
        "type": "command",
        "command": "jq -r '.tool_input.file_path' | xargs npx prettier --write"
      }]
    }]
  }
}
```

### rules/ — 경로 스코프 규칙

```markdown
---
paths:
  - "**/*.test.ts"
  - "**/*.test.tsx"
---

# Testing Rules

- Use descriptive test names: "should [expected] when [condition]"
- Mock external dependencies, not internal modules
- Clean up side effects in afterEach
```

### skills/ — 보안 리뷰 스킬

```markdown
---
description: Reviews code changes for security vulnerabilities
disable-model-invocation: true
argument-hint: <branch-or-path>
---

## Diff to review

!`git diff $ARGUMENTS`

Audit the changes above for:
1. Injection vulnerabilities (SQL, XSS, command)
2. Authentication and authorization gaps
3. Hardcoded secrets or credentials

Use checklist.md in this skill directory for the full review checklist.
```

### agents/ — 코드 리뷰 서브에이전트

```markdown
---
name: code-reviewer
description: Reviews code for correctness, security, and maintainability
tools: Read, Grep, Glob
---

You are a senior code reviewer. Review for:
1. Correctness: logic errors, edge cases, null handling
2. Security: injection, auth bypass, data exposure
3. Maintainability: naming, complexity, duplication

Every finding must include a concrete fix.
```

### output-styles/ — 교육 모드 스타일

```markdown
---
description: Explains reasoning and asks you to implement small pieces
keep-coding-instructions: true
---

After completing each task, add a brief "Why this approach" note
explaining the key design decision.

When a change is under 10 lines, ask the user to implement it
themselves by leaving a TODO(human) marker instead of writing it.
```

### .mcp.json — 프로젝트 MCP 서버

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_TOKEN": "${GITHUB_TOKEN}"
      }
    }
  }
}
```

### .worktreeinclude — worktree 복사 대상

```text
# Local environment
.env
.env.local

# API credentials
config/secrets.json
```

### ~/.claude.json — 글로벌 앱 상태

```json
{
  "editorMode": "vim",
  "showTurnDuration": false,
  "mcpServers": {
    "my-tools": {
      "command": "npx",
      "args": ["-y", "@example/mcp-server"]
    }
  }
}
```

### keybindings.json — 키보드 단축키

```json
{
  "$schema": "https://www.schemastore.org/claude-code-keybindings.json",
  "$docs": "https://code.claude.com/docs/en/keybindings",
  "bindings": [
    {
      "context": "Chat",
      "bindings": {
        "ctrl+e": "chat:externalEditor",
        "ctrl+u": null
      }
    }
  ]
}
```

- `Ctrl+C`, `Ctrl+D`, `Ctrl+M`은 예약 키로 리바인드할 수 없다.
- `/keybindings` 명령으로 파일 생성/편집이 가능하다.

### 자동 메모리 (projects/)

```
~/.claude/projects/<project>/memory/
├── MEMORY.md          # 매 세션 시작 시 로드 (200줄 또는 25KB까지)
├── build-and-test.md  # 토픽 파일 (관련 작업 시 온디맨드 로드)
├── architecture.md
└── debugging.md
```

- Claude가 작업하면서 자동으로 생성·관리한다. 사용자가 직접 작성하지 않는다.
- `/memory` 명령 또는 `autoMemoryEnabled` 설정으로 토글할 수 있다.
- MEMORY.md는 인덱스 역할을 하며, 토픽 파일을 참조한다.

### 설정 우선순위

설정 파일은 다음 순서로 적용된다 (아래가 우선):

1. `~/.claude/settings.json` — 글로벌 기본값
2. `.claude/settings.json` — 프로젝트 설정
3. `.claude/settings.local.json` — 개인 오버라이드
4. CLI 플래그 (`--permission-mode`, `--settings` 등) — 해당 세션에만 적용
5. managed settings (`managed-settings.json`) — 최우선. CLI 플래그로도 오버라이드 불가. 조직 IT/MDM 정책으로 배포되며 시스템 레벨 경로에 위치 (macOS: `/Library/Application Support/ClaudeCode/`)

- 배열 설정(예: `permissions.allow`)은 모든 스코프에서 합산된다.
- 스칼라 설정(예: `model`)은 가장 구체적인 값이 사용된다.

### 현재 로드된 파일 확인

세션에서 실제로 무엇이 로드되었는지 다음 명령어로 확인할 수 있다.

| 명령어            | 설명                                          |
| -------------- | ------------------------------------------- |
| `/context`     | 토큰 사용 현황: 시스템 프롬프트, 메모리 파일, 스킬, MCP 도구, 메시지 |
| `/memory`      | 로드된 CLAUDE.md, rules 파일, 자동 메모리 항목          |
| `/agents`      | 설정된 서브에이전트와 그 설정                            |
| `/hooks`       | 활성 hook 설정                                  |
| `/mcp`         | 연결된 MCP 서버와 상태                              |
| `/skills`      | 프로젝트·사용자·플러그인 소스의 가용 스킬                     |
| `/permissions` | 현재 allow/deny 규칙                            |
| `/doctor`      | 설치 및 설정 진단                                  |
