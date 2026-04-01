# Claude가 프로젝트를 기억하는 방법

> https://code.claude.com/docs/ko/memory

## 기본 개념

Claude Code는 세션 간 지식 전달을 위해 두 가지 메모리 시스템을 제공한다. 둘 다 모든 대화 시작 시 로드된다.

|           | CLAUDE.md 파일            | 자동 메모리                           |
| :-------- | :---------------------- | :------------------------------- |
| **작성자**   | 사용자                     | Claude                           |
| **포함 내용** | 지침 및 규칙                 | 학습 및 패턴                          |
| **범위**    | 프로젝트, 사용자 또는 조직         | 작업 트리당                           |
| **로드 대상** | 모든 세션                   | 모든 세션(`MEMORY.md` 인덱스의 처음 200줄)  |
| **사용 목적** | 코딩 표준, 워크플로우, 프로젝트 아키텍처 | 빌드 명령, 디버깅 인사이트, Claude가 발견한 선호도 |

---

## CLAUDE.md 파일

### 배치 위치와 범위

| 범위          | 위치                                                                                                                                                          | 목적                    | 공유 대상       |
| ----------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------- | ----------- |
| **관리 정책**   | macOS: `/Library/Application Support/ClaudeCode/CLAUDE.md`<br/>Linux/WSL: `/etc/claude-code/CLAUDE.md`<br/>Windows: `C:\Program Files\ClaudeCode\CLAUDE.md` | IT/DevOps 관리 조직 전체 지침 | 조직의 모든 사용자  |
| **프로젝트 지침** | `./CLAUDE.md` 또는 `./.claude/CLAUDE.md`                                                                                                                      | 팀 공유 프로젝트 지침          | 소스 제어를 통한 팀 |
| **사용자 지침**  | `~/.claude/CLAUDE.md`                                                                                                                                       | 모든 프로젝트에 대한 개인 선호도    | 본인만         |

- 작업 디렉토리에서 상위로 올라가며 CLAUDE.md를 모두 로드한다.
- 하위 디렉토리의 CLAUDE.md는 해당 디렉토리 파일을 읽을 때 지연 로드된다.
- `/init` 명령으로 초기 CLAUDE.md를 자동 생성할 수 있다.

### 효과적인 지침 작성 원칙

- **크기**: 파일당 200줄 이하를 목표로 한다.
- **구조**: 마크다운 헤더와 글머리 기호로 관련 지침을 그룹화한다.
- **구체성**: 검증 가능하게 작성한다. ("코드를 제대로 포맷합니다" → "2칸 들여쓰기 사용")
- **일관성**: 충돌하는 규칙이 있으면 Claude가 하나를 임의로 선택할 수 있다.

### 파일 가져오기

`@path/to/import` 구문으로 추가 파일을 가져올 수 있다. 최대 5홉 깊이까지 재귀 가져오기를 지원한다.

```text
프로젝트 개요는 @README를 참조하고 npm 명령은 @package.json을 참조한다.

# 개인 선호도
- @~/.claude/my-project-instructions.md
```

### 추가 디렉토리에서 로드

`--add-dir` 플래그로 주 작업 디렉토리 외부 디렉토리에 접근할 수 있다. 단, 해당 디렉토리의 CLAUDE.md를 로드하려면 환경 변수 설정이 필요하다.

```bash
CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1 claude --add-dir ../shared-config
```

### 주석

HTML 블록 주석(`<!-- ... -->`)을 사용하면 컨텍스트에 로드되지 않는 메모를 남길 수 있다. 사람이 파일을 직접 열면 보이지만, Claude의 세션에는 포함되지 않아 토큰을 절약한다.

```markdown
<!-- 이 섹션은 이슈 #234 대응으로 추가됨. 해결 시 제거할 것. -->

## 코드 스타일
- 2칸 들여쓰기 사용
```

코드 블록 내부의 HTML 주석은 제거되지 않고 그대로 유지된다.

### AGENTS.md 가져오기

`AGENTS.md`는 Claude Code의 기능이 아니라 다른 AI 코딩 도구(Cursor, Windsurf 등)가 사용하는 파일이다. 기존에 `AGENTS.md`를 사용하는 프로젝트라면 `@path` 구문으로 가져와서 지침을 중복 없이 공유할 수 있다.

```markdown
@AGENTS.md

## Claude Code 전용
- plan 모드로 `src/billing/` 변경 처리
```

### 특정 CLAUDE.md 제외

`.claude/settings.local.json`에서 `claudeMdExcludes`로 불필요한 파일을 건너뛸 수 있다.

```json
{
  "claudeMdExcludes": [
    "**/monorepo/CLAUDE.md",
    "/home/user/monorepo/other-team/.claude/rules/**"
  ]
}
```

---

## `.claude/rules/`로 규칙 구성

지침을 주제별 파일로 분리하여 모듈식으로 관리한다. 모든 `.md` 파일은 재귀적으로 발견된다.

```text
.claude/
├── CLAUDE.md
└── rules/
    ├── code-style.md
    ├── testing.md
    └── security.md
```

### 경로별 규칙

YAML frontmatter의 `paths` 필드로 특정 파일에만 규칙을 적용할 수 있다.

```markdown
---
paths:
  - "src/api/**/*.ts"
---

# API 개발 규칙
- 모든 API 엔드포인트는 입력 검증을 포함해야 한다
```

| 패턴 | 일치 대상 |
| --- | --- |
| `**/*.ts` | 모든 디렉토리의 TypeScript 파일 |
| `src/**/*` | `src/` 아래 모든 파일 |
| `*.md` | 프로젝트 루트의 마크다운 파일 |
| `src/components/*.tsx` | 특정 디렉토리의 React 컴포넌트 |

### 사용자 수준 규칙

`~/.claude/rules/`에 개인 규칙을 배치하면 모든 프로젝트에 적용된다. 사용자 규칙이 먼저 로드된 후 프로젝트 규칙이 로드되므로, 동일한 주제에 대해 프로젝트 규칙이 사용자 규칙을 덮어쓴다.

### 심볼릭 링크로 규칙 공유

```bash
ln -s ~/shared-claude-rules .claude/rules/shared
ln -s ~/company-standards/security.md .claude/rules/security.md
```

---

## 자동 메모리

Claude가 작업하면서 자동으로 노트를 저장하는 시스템이다. 빌드 명령, 디버깅 인사이트, 아키텍처 노트, 코드 스타일 선호도 등을 기록한다.

### 활성화/비활성화

- 기본값: 켜져 있음 (v2.1.59 이상 필요)
- `/memory` 명령으로 메모리 관리 UI를 열거나, 설정에서 변경한다.

```json
{ "autoMemoryEnabled": false }
```

- 환경 변수: `CLAUDE_CODE_DISABLE_AUTO_MEMORY=1`

### 저장 위치

```text
~/.claude/projects/<project>/memory/
├── MEMORY.md          # 인덱스, 모든 세션에 로드 (처음 200줄)
├── debugging.md       # 디버깅 패턴 노트
├── api-conventions.md # API 설계 결정
└── ...
```

- `<project>` 경로는 git 저장소에서 파생된다. 동일 저장소의 모든 worktree/하위 디렉토리가 하나의 메모리 디렉토리를 공유한다.
- 커스텀 위치 설정: `"autoMemoryDirectory": "~/my-custom-memory-dir"` (정책/로컬/사용자 설정에서 허용, 프로젝트 설정에서는 불가)

### 작동 방식

- `MEMORY.md`의 처음 200줄만 세션 시작 시 로드된다.
- 주제 파일(`debugging.md` 등)은 필요할 때 Claude가 직접 읽는다.
- `/memory` 명령으로 저장된 메모리를 탐색, 편집, 삭제할 수 있다.

---

## 문제 해결

| 문제                        | 해결 방법                                                   |
| ------------------------- | ------------------------------------------------------- |
| Claude가 CLAUDE.md를 따르지 않음 | `/memory`로 로드 확인 → 지침을 더 구체적으로 작성 → 충돌하는 규칙 제거          |
| 자동 메모리 내용 확인              | `/memory` 실행 → 자동 메모리 폴더 선택 → 마크다운 파일 직접 편집/삭제          |
| CLAUDE.md가 너무 큼           | `@path` 가져오기 또는 `.claude/rules/` 파일로 분할                 |
| `/compact` 후 지침 손실        | CLAUDE.md는 압축 후 재로드됨. 대화에서만 제공한 지침은 사라지므로 CLAUDE.md에 추가 |
| 시스템 프롬프트 수준 지침 필요         | `--append-system-prompt` 플래그 사용 (스크립트/자동화 용도)           |
| 지침 로드 디버깅                 | `InstructionsLoaded` hook으로 로드된 파일과 시기를 기록              |
