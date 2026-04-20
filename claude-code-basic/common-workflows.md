# 일반적인 워크플로우

> https://code.claude.com/docs/ko/common-workflows

## 기본 개념

Claude Code를 활용한 일상적인 개발 워크플로우 가이드다. 코드베이스 탐색, 버그 수정, 리팩토링, 테스트, PR 생성, 세션 관리 등 실용적인 패턴을 다룬다.

| 워크플로우    | 핵심 포인트                            |
| -------- | --------------------------------- |
| 코드베이스 이해 | 광범위한 질문 → 구체적 영역으로 좁혀가기           |
| 버그 수정    | 오류 메시지·스택 추적 공유 → 수정안 요청 → 적용     |
| 리팩토링     | 레거시 코드 식별 → 권장사항 → 변경 적용 → 테스트 검증 |
| 테스트 작업   | 미적용 코드 식별 → 스캐폴딩 → 엣지 케이스 추가 → 실행 |
| PR 생성    | 변경사항 요약 → PR 생성 → 검토·정제           |
| 문서 처리    | 미문서화 코드 식별 → 문서 생성 → 검토·검증        |

## 옵션

### Plan Mode

코드베이스를 읽기 전용으로 분석하여 계획을 세우는 모드다.

| 옵션                              | 설명                               | 기본값 |
| ------------------------------- | -------------------------------- | --- |
| `Shift+Tab`                     | 세션 중 Plan Mode 전환                | -   |
| `--permission-mode plan`        | Plan Mode로 새 세션 시작               | -   |
| `-p` + `--permission-mode plan` | 헤드리스 모드에서 Plan Mode 실행           | -   |
| `Ctrl+G`                        | 기본 편집기에서 계획 열기·편집                | -   |
| `defaultMode: "plan"`           | `.claude/settings.json`에서 기본값 설정 | -   |

### 확장된 사고 (Thinking Mode)

복잡한 문제를 단계별로 추론하는 기능이다. 기본 활성화 상태다.

| 옵션 | 설명 | 비고 |
|---|---|---|
| `/effort` | 노력 수준 조정 | 적응형 추론은 Opus 4.6, Sonnet 4.6 |
| `ultrathink` | 프롬프트에 포함 시 해당 턴 높은 노력 | 일회성 사용 |
| `Option+T` / `Alt+T` | 사고 켜기/끄기 토글 | 현재 세션 |
| `/config` | 전역 기본값 설정 | `alwaysThinkingEnabled` |
| `MAX_THINKING_TOKENS` | 사고 토큰 예산 제한 | 환경 변수 |
| `Ctrl+O` | 자세한 모드 토글 (사고 과정 보기) | - |
| `showThinkingSummaries` | 사고 요약 표시 여부 설정 | `settings.json`에 직접 추가 |

### 세션 관리

| 명령 | 설명 |
|---|---|
| `claude --continue` | 가장 최근 대화 계속 |
| `claude --resume` | 대화 선택기 열기 |
| `claude --resume <name>` | 이름으로 재개 |
| `claude --from-pr 123` | PR에 연결된 세션 재개 |
| `claude -n <name>` | 이름 지정하여 시작 |
| `/rename <name>` | 세션 이름 변경 |
| `/resume` | 세션 내에서 다른 대화로 전환 |

**세션 선택기 단축키:**

| 단축키 | 작업 |
|---|---|
| `↑`/`↓` | 세션 간 이동 |
| `→`/`←` | 그룹 확장/축소 |
| `Enter` | 세션 선택·재개 |
| `P` | 미리보기 |
| `R` | 이름 바꾸기 |
| `/` | 검색 필터 |
| `A` | 전체 프로젝트 전환 |
| `B` | 현재 브랜치 필터 |

### Git Worktree

병렬 세션을 위해 격리된 작업 디렉토리를 생성한다.

| 명령 | 설명 |
|---|---|
| `claude --worktree <name>` | 이름 지정 worktree 생성·시작 |
| `claude --worktree` | 랜덤 이름 자동 생성 |
| `claude -w <name>` | 단축 플래그 |

- Worktree는 `<repo>/.claude/worktrees/<name>`에 생성된다.
- 분기명은 `worktree-<name>`이다.
- 변경사항 없으면 종료 시 자동 정리된다.
- `.worktreeinclude` 파일로 gitignored 파일(`.env` 등) 자동 복사를 설정한다.
- Subagent에서도 `isolation: worktree`로 사용 가능하다.

### 예약 실행

| 옵션 | 실행 위치 | 최적 사용 |
|---|---|---|
| 클라우드 예약 작업 | Anthropic 관리 인프라 | 컴퓨터 꺼져도 실행 필요한 작업 |
| 데스크톱 예약 작업 | 로컬 컴퓨터 | 로컬 파일·도구 접근 필요한 작업 |
| GitHub Actions | CI 파이프라인 | 저장소 이벤트 연결 작업 |
| `/loop` | 현재 CLI 세션 | 세션 중 빠른 폴링 |

### 알림 설정

`Notification` hook을 `~/.claude/settings.json`에 추가하여 Claude가 주의를 필요로 할 때 데스크톱 알림을 받는다.

| Matcher | 발생 시기 |
|---|---|
| `permission_prompt` | 도구 사용 승인 요청 시 |
| `idle_prompt` | 작업 완료 후 대기 시 |
| `auth_success` | 인증 완료 시 |
| `elicitation_dialog` | 질문 시 |

## 사용 예시

### 코드베이스 탐색

```text
give me an overview of this codebase
explain the main architecture patterns used here
how is authentication handled?
```

### 버그 수정

```text
I'm seeing an error when I run npm test
suggest a few ways to fix the @ts-ignore in user.ts
```

### Subagent 활용

```text
/agents                          # 사용 가능한 subagent 확인
review my recent code changes for security issues
use the code-reviewer subagent to check the auth module
```

### 이미지 분석

```text
Analyze this image: /path/to/image.png
Generate CSS to match this design mockup
```

### 파일 참조 (@)

```text
Explain the logic in @src/utils/auth.js      # 파일 참조
What's the structure of @src/components       # 디렉토리 참조
Show me the data from @github:repos/owner/repo/issues  # MCP 리소스
```

### Unix 스타일 파이프

```bash
# 빌드 에러 분석
cat build-error.txt | claude -p 'concisely explain the root cause' > output.txt

# 린터로 사용
claude -p 'you are a linter. look at changes vs. main and report typos.'

# JSON 출력
cat code.py | claude -p 'analyze this code' --output-format json > analysis.json

# 스트리밍 JSON 출력
cat log.txt | claude -p 'parse errors' --output-format stream-json
```

### Plan Mode에서 리팩토링 계획

```bash
claude --permission-mode plan
```

```text
I need to refactor our authentication system to use OAuth2.
Create a detailed migration plan.
```
