# Skills 치트시트

> 원본: [Skills](https://code.claude.com/docs/ko/skills)

## 기본 개념

- **Skill**: `SKILL.md` 파일로 Claude의 기능을 확장하는 단위이다. Claude가 자동 호출하거나 `/skill-name`으로 직접 호출한다.
- **번들 Skill**: Claude Code에 기본 내장된 skill이다.
- Skills는 [Agent Skills](https://agentskills.io) 개방형 표준을 따른다.
- 기존 `.claude/commands/` 파일도 계속 작동하며, 동일한 frontmatter를 지원한다. 같은 이름일 경우 skill이 우선한다.

### Skill 저장 위치와 적용 범위

| 위치 | 경로 | 적용 대상 |
|------|------|-----------|
| Enterprise | 관리 설정 참조 | 조직 전체 |
| Personal | `~/.claude/skills/<name>/SKILL.md` | 모든 프로젝트 |
| Project | `.claude/skills/<name>/SKILL.md` | 해당 프로젝트만 |
| Plugin | `<plugin>/skills/<name>/SKILL.md` | 플러그인 활성화된 곳 |

- 우선순위: enterprise > personal > project
- Plugin skill은 `plugin-name:skill-name` 네임스페이스를 사용하므로 충돌 없음
- Monorepo에서는 하위 디렉토리의 `.claude/skills/`도 자동 검색

### Skill 디렉토리 구조

```
my-skill/
├── SKILL.md           # 주요 지침 (필수)
├── template.md        # Claude가 채울 템플릿
├── examples/
│   └── sample.md      # 예상 형식을 보여주는 예제
└── scripts/
    └── validate.sh    # Claude가 실행할 스크립트
```

## 번들 Skills

| Skill | 설명 | 사용 예시 |
|-------|------|----------|
| `/simplify` | 변경된 코드를 재사용/품질/효율성 관점에서 검토 후 수정. 3개 검토 에이전트를 병렬 생성 | `/simplify focus on memory efficiency` |
| `/batch <instruction>` | 대규모 변경을 병렬로 조율. 5~30개 단위로 분해 후 각각 격리된 worktree에서 실행하여 PR 생성 | `/batch migrate src/ from Solid to React` |
| `/debug [description]` | 세션 디버그 로그를 읽어 현재 세션 문제 해결 | `/debug` |
| `/loop [interval] <prompt>` | 프롬프트를 간격에 따라 반복 실행 | `/loop 5m check if the deploy finished` |
| `/claude-api` | Claude API/SDK 참조 자료 로드. `anthropic` 등 임포트 시 자동 활성화 | `/claude-api` |

## 옵션 (Frontmatter 필드)

`SKILL.md` 상단 `---` 사이에 YAML로 작성한다. **모든 필드는 선택 사항**이며 `description`만 권장한다.

| 필드 | 설명 | 기본값 |
|------|------|--------|
| `name` | 표시 이름 (`/slash-command`가 됨). 소문자, 숫자, 하이픈만 가능 (최대 64자) | 디렉토리 이름 |
| `description` | 수행 내용과 사용 시기. Claude가 자동 호출 판단에 사용 | 본문 첫 단락 |
| `argument-hint` | 자동완성에서 보이는 인수 힌트 (예: `[issue-number]`) | - |
| `disable-model-invocation` | `true`면 Claude 자동 호출 차단. 수동 트리거만 허용 | `false` |
| `user-invocable` | `false`면 `/` 메뉴에서 숨김. 배경 지식용 | `true` |
| `allowed-tools` | skill 활성 시 권한 요청 없이 사용 가능한 도구 목록 | - |
| `model` | skill 활성 시 사용할 모델 | - |
| `context` | `fork`로 설정하면 subagent에서 실행 | - |
| `agent` | `context: fork` 시 사용할 subagent 유형 (`Explore`, `Plan`, `general-purpose` 또는 커스텀) | `general-purpose` |
| `hooks` | skill 라이프사이클에 범위 지정된 hooks | - |

### 호출 제어 조합

| Frontmatter | 사용자 호출 | Claude 호출 | 컨텍스트 로딩 |
|-------------|-----------|------------|------------|
| (기본값) | O | O | 설명 항상 로드, 호출 시 전체 로드 |
| `disable-model-invocation: true` | O | X | 설명 미로드, 사용자 호출 시 전체 로드 |
| `user-invocable: false` | X | O | 설명 항상 로드, 호출 시 전체 로드 |

## 문자열 치환 변수

| 변수 | 설명 |
|------|------|
| `$ARGUMENTS` | 호출 시 전달된 모든 인수. 콘텐츠에 없으면 `ARGUMENTS: <value>`로 자동 추가 |
| `$ARGUMENTS[N]` | 0 기반 인덱스로 특정 인수 접근 (예: `$ARGUMENTS[0]`) |
| `$N` | `$ARGUMENTS[N]`의 약자 (예: `$0`, `$1`) |
| `${CLAUDE_SESSION_ID}` | 현재 세션 ID |
| `${CLAUDE_SKILL_DIR}` | `SKILL.md`가 위치한 디렉토리 경로 |

## 사용 예시

### 기본 skill 생성

```yaml
# ~/.claude/skills/explain-code/SKILL.md
---
name: explain-code
description: Explains code with visual diagrams and analogies. Use when explaining how code works.
---

When explaining code, always include:

1. **Start with an analogy**: Compare the code to something from everyday life
2. **Draw a diagram**: Use ASCII art to show the flow
3. **Walk through the code**: Explain step-by-step
4. **Highlight a gotcha**: Common mistake or misconception?
```

### 인수를 받는 skill

```yaml
---
name: fix-issue
description: Fix a GitHub issue
disable-model-invocation: true
---

Fix GitHub issue $ARGUMENTS following our coding standards.

1. Read the issue description
2. Implement the fix
3. Write tests
4. Create a commit
```

호출: `/fix-issue 123`

### 위치별 인수 접근

```yaml
---
name: migrate-component
description: Migrate a component from one framework to another
---

Migrate the $0 component from $1 to $2.
Preserve all existing behavior and tests.
```

호출: `/migrate-component SearchBar React Vue`

### 동적 컨텍스트 주입 (셸 명령 전처리)

`` !`command` `` 구문으로 skill 전송 전에 셸 명령을 실행하여 결과를 삽입한다.

```yaml
---
name: pr-summary
description: Summarize changes in a pull request
context: fork
agent: Explore
allowed-tools: Bash(gh *)
---

## Pull request context
- PR diff: !`gh pr diff`
- PR comments: !`gh pr view --comments`
- Changed files: !`gh pr diff --name-only`

## Your task
Summarize this pull request...
```

### Subagent에서 실행하는 skill

```yaml
---
name: deep-research
description: Research a topic thoroughly
context: fork
agent: Explore
---

Research $ARGUMENTS thoroughly:

1. Find relevant files using Glob and Grep
2. Read and analyze the code
3. Summarize findings with specific file references
```

### 도구 접근 제한 (읽기 전용)

```yaml
---
name: safe-reader
description: Read files without making changes
allowed-tools: Read, Grep, Glob
---
```

### 참조 콘텐츠형 skill

```yaml
---
name: api-conventions
description: API design patterns for this codebase
---

When writing API endpoints:
- Use RESTful naming conventions
- Return consistent error formats
- Include request validation
```

## Skills vs Subagents

| 접근 방식 | 시스템 프롬프트 | 작업 | 추가 로드 |
|-----------|-------------|------|----------|
| `context: fork` Skill | 에이전트 유형에서 | SKILL.md 콘텐츠 | CLAUDE.md |
| `skills` 필드의 Subagent | Subagent markdown 본문 | Claude의 위임 메시지 | 사전 로드된 skills + CLAUDE.md |

## 권한 제어

```text
# 모든 skill 비활성화 (deny 규칙에 추가)
Skill

# 특정 skill만 허용
Skill(commit)
Skill(review-pr *)

# 특정 skill 거부
Skill(deploy *)
```

- 정확한 일치: `Skill(name)`
- 인수 포함 접두사 일치: `Skill(name *)`

## 문제 해결

| 문제                    | 해결 방법                                                                                              |
| --------------------- | -------------------------------------------------------------------------------------------------- |
| Skill이 트리거되지 않음       | description에 사용자가 쓸 키워드 포함 확인. `What skills are available?`로 목록 확인                                 |
| Skill이 너무 자주 트리거됨     | description을 더 구체적으로 수정하거나 `disable-model-invocation: true` 추가                                     |
| Claude가 모든 skill을 못 봄 | 설명이 컨텍스트 예산(윈도우의 2%, 폴백 16,000자) 초과. `/context`로 확인. `SLASH_COMMAND_TOOL_CHAR_BUDGET` 환경변수로 재정의 가능 |

## 팁

- `SKILL.md`는 500줄 이하로 유지하고, 상세 참조는 별도 파일로 분리한다.
- 지원 파일은 `SKILL.md`에서 참조하여 Claude가 각 파일의 용도와 로드 시기를 알 수 있게 한다.
- 확장 사고(extended thinking)를 활성화하려면 skill 콘텐츠에 "ultrathink"를 포함한다.
- `--add-dir`로 추가된 디렉토리의 skill은 자동 로드되며, 세션 중 편집해도 실시간 반영된다.
