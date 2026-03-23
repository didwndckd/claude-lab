# 에이전트 팀(Agent Teams)

> 원본: [https://code.claude.com/docs/ko/agent-teams](https://code.claude.com/docs/ko/agent-teams)

## 기본 개념

- **에이전트 팀**: 여러 Claude Code 인스턴스가 공유 작업 목록과 메시징을 통해 협업하는 구조
- **팀 리더**: 팀을 생성하고, 팀원을 생성하며, 작업을 조율하는 메인 세션
- **팀원**: 할당된 작업을 독립적으로 수행하는 별도의 Claude Code 인스턴스
- **작업 목록**: 팀 전체가 공유하는 작업 항목 목록 (대기 중 → 진행 중 → 완료됨)
- **메일박스**: 에이전트 간 직접 통신을 위한 메시징 시스템
- **자동 제안**: Claude가 작업이 병렬 처리에 적합하다고 판단하면 팀 생성을 자동 제안할 수 있다
- **실험적 기능**: 기본 비활성화, Claude Code v2.1.32 이상 필요

### Subagent vs 에이전트 팀
![subagents-vs-agent-teams-dark](Assets/subagents-vs-agent-teams-dark.png)

| 항목        | Subagent                  | 에이전트 팀               |
| --------- | ------------------------- | -------------------- |
| **컨텍스트**  | 자체 컨텍스트 윈도우, 결과를 호출자에게 반환 | 자체 컨텍스트 윈도우, 완전히 독립적 |
| **통신**    | 메인 에이전트에게만 보고             | 팀원 간 직접 메시지 전송       |
| **조율**    | 메인 에이전트가 모든 작업 관리         | 공유 작업 목록으로 자체 조율     |
| **최적 용도** | 결과만 중요한 집중된 작업            | 논의와 협업이 필요한 복잡한 작업   |
| **토큰 비용** | 낮음 (결과가 메인 컨텍스트로 요약)      | 높음 (각 팀원이 별도 인스턴스)   |

### 에이전트 팀이 효과적인 경우

- 연구 및 검토: 여러 팀원이 다양한 측면을 동시에 조사
- 새로운 모듈/기능: 각 팀원이 별도 부분을 소유
- 경쟁 가설 디버깅: 다양한 이론을 병렬로 테스트
- 교차 계층 조율: 프론트엔드/백엔드/테스트를 각각 다른 팀원이 소유

### 에이전트 팀이 비효과적인 경우

- 순차적 작업, 동일 파일 편집, 종속성이 많은 작업 → 단일 세션 또는 subagent 사용

## 옵션

### 활성화 설정

| 옵션                                     | 설명                                            | 기본값        |
| -------------------------------------- | --------------------------------------------- | ---------- |
| `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` | 에이전트 팀 기능 활성화                                 | `0` (비활성화) |
| `teammateMode`                         | 표시 모드 설정 (`"auto"`, `"in-process"`, `"tmux"`) | `"auto"`   |
| `--teammate-mode`                      | CLI 플래그로 단일 세션 표시 모드 지정                       | -          |

### 표시 모드

| 모드            | 설명                               | 요구사항                                        |
| ------------- | -------------------------------- | ------------------------------------------- |
| `in-process`  | 모든 팀원이 메인 터미널 내에서 실행             | 없음 (모든 터미널)                                 |
| 분할 창 (`tmux`) | 각 팀원이 자신의 창을 가짐                  | tmux 또는 iTerm2 + `it2` CLI + Python API 활성화 |
| `auto` (기본)   | tmux 세션 내이면 분할 창, 아니면 in-process | -                                           |

### 키보드 단축키 (in-process 모드)

| 키            | 동작                      |
| ------------ | ----------------------- |
| `Shift+Down` | 팀원 간 순환 (마지막 이후 리더로 복귀) |
| `Enter`      | 팀원 세션 보기                |
| `Escape`     | 현재 턴 중단                 |
| `Ctrl+T`     | 작업 목록 전환                |

### 작업 상태

| 상태 | 설명 |
|------|------|
| 대기 중 | 아직 시작되지 않은 작업 |
| 진행 중 | 팀원이 작업 중 |
| 완료됨 | 작업 완료 |

작업은 다른 작업에 **종속**될 수 있다. 종속성이 완료될 때까지 해당 작업은 요청 불가.

### Hooks

| Hook | 시점 | 종료 코드 2 동작 |
|------|------|-----------------|
| `TeammateIdle` | 팀원이 유휴 상태가 되려 할 때 | 피드백을 보내고 팀원을 계속 작동 |
| `TaskCompleted` | 작업이 완료로 표시될 때 | 완료를 방지하고 피드백 전송 |

### 저장 경로

| 항목 | 경로 |
|------|------|
| 팀 구성 | `~/.claude/teams/{team-name}/config.json` |
| 작업 목록 | `~/.claude/tasks/{team-name}/` |

### 권한

- 팀원은 리더의 권한 설정을 상속한다
- `--dangerously-skip-permissions`로 실행 시 모든 팀원도 동일하게 적용
- 생성 후 개별 팀원 모드 변경 가능, 생성 시 팀원별 모드 설정 불가

### 컨텍스트

- 각 팀원은 자체 컨텍스트 윈도우를 가진다
- 프로젝트 컨텍스트 자동 로드: CLAUDE.md, MCP servers, skills
- **리더의 대화 기록은 전달되지 않는다** → 생성 프롬프트에 작업별 세부 사항 포함 필요

### 통신 방식

| 방식 | 설명 |
|------|------|
| `message` | 특정 팀원 한 명에게 메시지 전송 |
| `broadcast` | 모든 팀원에게 동시 전송 (비용 증가, 드물게 사용) |
| 자동 전달 | 메시지 발송 시 자동으로 수신자에게 전달 |
| 유휴 알림 | 팀원 완료/중지 시 리더에게 자동 알림 |

## 사용 예시

### 활성화

```json
// settings.json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

### 기본 팀 생성

```text
I'm designing a CLI tool that helps developers track TODO comments across
their codebase. Create an agent team to explore this from different angles: one
teammate on UX, one on technical architecture, one playing devil's advocate.

코드베이스 전체에서 TODO 주석을 추적하는 CLI 도구를 설계하고 있어. 에이전트 팀을 만들어서
다양한 각도로 탐색해줘: 한 명은 UX, 한 명은 기술 아키텍처, 한 명은 반대 의견 역할.
```

### 팀원 수와 모델 지정

```text
Create a team with 4 teammates to refactor these modules in parallel.
Use Sonnet for each teammate.

4명의 팀원으로 팀을 만들어서 이 모듈들을 병렬로 리팩토링해줘. 각 팀원은 Sonnet을 사용해.
```

### 계획 승인 요구 (Plan Approval)

```text
Spawn an architect teammate to refactor the authentication module.
Require plan approval before they make any changes.

인증 모듈을 리팩토링할 아키텍트 팀원을 생성해줘. 변경 전에 계획 승인을 필수로 해.
```

계획 승인 흐름: 팀원이 **읽기 전용 계획 모드**에서 계획 작성 → 리더에게 승인 요청 → 승인 시 구현 시작 / 거부 시 피드백 반영 후 재제출

리더의 승인 기준을 프롬프트에 명시할 수 있다:
```text
Only approve plans that include test coverage
Reject plans that modify database schema

테스트 커버리지를 포함한 계획만 승인해. 데이터베이스 스키마를 수정하는 계획은 거부해.
```

### 상세한 컨텍스트를 포함한 팀원 생성

```text
Spawn a security reviewer teammate with the prompt: "Review the authentication module
at src/auth/ for security vulnerabilities. Focus on token handling, session
management, and input validation. The app uses JWT tokens stored in
httpOnly cookies. Report any issues with severity ratings."

보안 검토 팀원을 생성해줘. 프롬프트: "src/auth/의 인증 모듈에서 보안 취약점을 검토해.
토큰 처리, 세션 관리, 입력 검증에 집중해. 앱은 httpOnly 쿠키에 저장된 JWT 토큰을
사용해. 심각도 등급과 함께 문제를 보고해."
```

### 병렬 코드 검토

```text
Create an agent team to review PR #142. Spawn three reviewers:
- One focused on security implications
- One checking performance impact
- One validating test coverage
Have them each review and report findings.

PR #142를 검토할 에이전트 팀을 만들어. 세 명의 검토자를 생성해:
- 한 명은 보안 영향에 집중
- 한 명은 성능 영향 확인
- 한 명은 테스트 커버리지 검증
각자 검토하고 결과를 보고하게 해.
```

### 경쟁 가설 디버깅

```text
Users report the app exits after one message instead of staying connected.
Spawn 5 agent teammates to investigate different hypotheses. Have them talk to
each other to try to disprove each other's theories, like a scientific
debate. Update the findings doc with whatever consensus emerges.

사용자들이 앱이 연결을 유지하지 않고 메시지 하나 후 종료된다고 보고해.
5명의 에이전트 팀원을 생성해서 각기 다른 가설을 조사해. 서로 대화하면서
상대방의 이론을 반박하도록 해, 과학적 토론처럼. 합의된 결론으로 결과 문서를 업데이트해.
```

### 팀원 종료

```text
Ask the researcher teammate to shut down

연구 팀원에게 종료하라고 요청해
```

### 팀 정리

```text
Clean up the team

팀을 정리해
```

> 반드시 리더를 통해 정리한다. 팀원이 정리를 실행하면 리소스가 불일치 상태가 될 수 있다.
> 활성 팀원이 남아있으면 정리가 실패하므로, 정리 전에 모든 팀원을 먼저 종료해야 한다.

### 팀원 대기 지시

```text
Wait for your teammates to complete their tasks before proceeding

팀원들이 작업을 완료할 때까지 기다린 후 진행해
```

### 표시 모드 강제

```bash
claude --teammate-mode in-process
```

```json
// settings.json
{
  "teammateMode": "in-process"
}
```

## 모범 사례

| 항목 | 권장 |
|------|------|
| 팀 크기 | 3~5명으로 시작 (하드 제한 없음, 실질적 제약 존재) |
| 팀원당 작업 수 | 5~6개가 적절 |
| 작업 크기 | 함수, 테스트 파일, 검토 등 자체 포함된 단위 |
| 파일 충돌 방지 | 각 팀원이 다른 파일 집합을 소유하도록 분할 |
| 첫 시작 | 코드 작성 없는 연구/검토 작업으로 시작 |
| 모니터링 | 진행 상황 확인, 잘못된 접근 재지정, 결과 종합 |

## 제한 사항

- **세션 재개 없음**: `/resume`, `/rewind`로 in-process 팀원 복원 불가
- **작업 상태 지연**: 팀원이 작업 완료를 표시하지 못해 종속 작업이 차단될 수 있음
- **종료 지연**: 현재 요청/도구 호출 완료 후 종료
- **세션당 한 팀**: 새 팀 시작 전 현재 팀 정리 필요
- **중첩 불가**: 팀원이 자체 팀/팀원 생성 불가
- **리더 고정**: 팀 생성 세션이 수명 동안 리더, 이전 불가
- **권한 상속**: 생성 시 팀원별 권한 모드 개별 설정 불가
- **분할 창 제한**: VS Code 통합 터미널, Windows Terminal, Ghostty 미지원
- **CLAUDE.md는 정상 작동**: 팀원들이 작업 디렉토리의 CLAUDE.md를 읽음

## 문제 해결

| 문제 | 해결 방법 |
|------|----------|
| 팀원이 나타나지 않음 | `Shift+Down`으로 확인 / 작업 복잡도 확인 / `which tmux` 확인 |
| 권한 프롬프트 과다 | 팀원 생성 전 일반적인 작업 사전 승인 |
| 팀원 오류 중지 | 직접 지시 제공 또는 대체 팀원 생성 |
| 리더 조기 종료 | "계속하라"고 지시 |
| 고아 tmux 세션 | `tmux ls` → `tmux kill-session -t <session-name>` |
