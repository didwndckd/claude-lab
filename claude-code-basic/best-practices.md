# Claude Code 모범 사례

> https://code.claude.com/docs/ko/best-practices

## 기본 개념

- Claude Code는 에이전트 코딩 환경이다. 파일 읽기, 명령 실행, 변경 수행을 자율적으로 처리한다.
- **context window**가 가장 중요한 리소스이다. 채워질수록 성능이 저하된다.
- 모든 메시지, 읽은 파일, 명령 출력이 context window에 포함된다.

| 핵심 원칙        | 설명                                                       |
| ------------ | -------------------------------------------------------- |
| 검증 수단 제공     | 테스트, 스크린샷, 예상 출력으로 Claude가 스스로 작업을 확인하도록 한다              |
| 탐색 → 계획 → 구현 | Plan Mode로 연구와 실행을 분리한다                                  |
| 구체적 컨텍스트 제공  | 파일, 제약 조건, 패턴을 명시한다                                      |
| context 관리   | `/clear`, subagent, `/compact`, `/btw`로 context를 적극 관리한다 |

## 옵션

### 검증 전략

| 전략 | 이전 | 이후 |
| --- | --- | --- |
| 검증 기준 제공 | "이메일 검증 함수 구현" | "validateEmail 작성 후 테스트 케이스 실행" |
| UI 시각적 검증 | "대시보드 개선" | "스크린샷 비교 후 차이점 수정" |
| 근본 원인 해결 | "빌드 실패" | "오류 붙여넣기 후 근본 원인 해결 요청" |

### 프롬프트 전략

| 전략 | 설명 |
| --- | --- |
| 작업 범위 지정 | 파일, 시나리오, 테스트 선호도를 명시한다 |
| 소스 지적 | git 히스토리 등 답을 찾을 수 있는 소스로 안내한다 |
| 기존 패턴 참조 | 코드베이스의 기존 구현을 예시로 지정한다 |
| 증상 설명 | 증상, 위치, "수정됨"의 기준을 함께 제공한다 |

### 환경 구성

| 항목 | 설명 |
| --- | --- |
| CLAUDE.md | `/init`으로 생성. 빌드 명령, 코드 스타일, 워크플로우 규칙을 간결하게 기록한다 |
| 권한 설정 | Auto mode, 허용 목록(`/permissions`), 샌드박싱(`/sandbox`) 중 선택한다 |
| CLI 도구 | `gh`, `aws`, `gcloud` 등을 설치하여 외부 서비스와 상호작용한다 |
| MCP 서버 | `claude mcp add`로 Notion, Figma, DB 등 외부 도구를 연결한다 |
| Hooks | 매번 반드시 실행해야 할 작업을 결정론적으로 보장한다 |
| Skills | `.claude/skills/`에 도메인 지식과 재사용 워크플로우를 정의한다 |
| Subagents | `.claude/agents/`에 전문화된 어시스턴트를 정의한다 |
| Plugins | `/plugin`으로 마켓플레이스에서 설치한다 |

### CLAUDE.md 작성 기준

| 포함할 것 | 제외할 것 |
| --- | --- |
| Claude가 추측할 수 없는 Bash 명령 | 코드를 읽어서 파악 가능한 것 |
| 기본값과 다른 코드 스타일 규칙 | 표준 언어 규칙 |
| 테스트 지시사항 및 선호 러너 | 상세한 API 문서 |
| 저장소 에티켓(분기 이름, PR 규칙) | 자주 변경되는 정보 |
| 프로젝트 특정 아키텍처 결정 | 긴 설명 또는 튜토리얼 |
| 개발 환경 특이성(필수 환경 변수) | 자명한 관행 |
| 일반적 함정 또는 비명시적 동작 | 파일별 코드베이스 설명 |

## 사용 예시

### 4단계 워크플로우

```
1. 탐색  — Plan Mode에서 코드 읽기
2. 계획  — 구현 계획 작성 (Ctrl+G로 편집)
3. 구현  — Normal Mode로 전환하여 코드 작성
4. 커밋  — 설명적 메시지로 커밋 및 PR 생성
```

### 풍부한 컨텍스트 제공

```bash
# @로 파일 참조
@src/auth/login.ts를 읽고 세션 흐름을 설명하세요

# 이미지 직접 붙여넣기 (복사/붙여넣기 또는 드래그 앤 드롭)

# 데이터 파이프
cat error.log | claude

# URL로 문서 제공 (/permissions로 도메인 허용 목록 추가)
```

### 세션 관리

```bash
# 방향 수정
Esc           — 작업 중지 (context 보존)
Esc + Esc     — rewind 메뉴 열기
/rewind       — rewind 메뉴 열기 (대화, 코드, 또는 둘 다 복원 가능)
/clear        — context 초기화
/btw [질문]    — 사이드 질문 (context에 추가되지 않음)

# 대화 재개
claude --continue   # 최근 대화 재개
claude --resume     # 대화 목록에서 선택
```

### `/btw`로 빠른 질문

```
/btw 이 설정 파일 이름이 뭐였지?
```

- 현재 대화의 전체 컨텍스트를 참조하여 답변한다.
- 질문과 답변이 대화 기록에 추가되지 않으므로 context를 소비하지 않는다.
- 도구 사용 불가 — 이미 컨텍스트에 있는 정보만으로 답변한다.
- Claude 작업 중에도 사용 가능하며 주 작업을 중단하지 않는다.
- subagent의 역(逆): `/btw`는 전체 대화를 보지만 도구 없음, subagent는 전체 도구를 갖지만 빈 컨텍스트로 시작.

### subagent로 조사 위임

```
subagents를 사용하여 인증 시스템이 토큰 새로 고침을 어떻게
처리하는지 조사하세요.
```

### 병렬 세션 — Writer/Reviewer 패턴

```
세션 A (작성자): API 속도 제한기 구현
세션 B (검토자): 세션 A의 코드를 엣지 케이스, 경쟁 조건 관점에서 검토
세션 A: 검토 피드백 반영
```

### 파일 전체에 fan out

여러 파일에 동일한 작업을 병렬로 분배하는 패턴이다. 각 호출이 독립된 context를 가지므로 context 오염이 없다.

**3단계 워크플로우:**

```bash
# 1단계: 작업 목록 생성
claude -p "마이그레이션이 필요한 모든 Python 파일을 files.txt에 저장해"

# 2단계: 루프 스크립트 작성
for file in $(cat files.txt); do
  claude -p "React에서 Vue로 $file 마이그레이션. OK 또는 FAIL 반환." \
    --allowedTools "Edit,Bash(git commit *)"
done

# 3단계: 소규모 테스트 후 프롬프트 개선, 그 다음 전체 실행
head -3 files.txt | while read file; do
  claude -p "React에서 Vue로 $file 마이그레이션" \
    --allowedTools "Edit,Bash(git commit *)"
done
```

**파이프라인 통합:**

```bash
# Claude 출력을 다른 명령에 연결
claude -p "API 엔드포인트를 JSON으로 나열" --output-format json | jq '.endpoints[]'

# 디버깅 시 --verbose 사용
claude -p "분석해줘" --verbose --output-format json
```

- `--allowedTools` — 무인 실행 시 Claude가 할 수 있는 작업을 제한한다.
- 파일 간 의존성이 강한 작업에는 부적합하다. 독립적이고 동일한 패턴의 작업일 때 효과적이다.

**fan out vs subagent:**

| | fan out (`claude -p` 루프) | subagent |
| --- | --- | --- |
| 실행 환경 | 완전히 독립된 프로세스 | 같은 세션 내 별도 context |
| 결과 수집 | stdout/파일로 직접 수집 | 부모 세션 context에 요약 반환 |
| 병렬성 | OS 수준 병렬 실행 (`&`, `xargs -P`) | Claude가 판단하여 병렬/순차 실행 |
| 권한 제어 | `--allowedTools`로 명시적 제한 | 부모 세션의 권한 설정을 따름 |

- 수십 개 이상의 대규모 일괄 처리, CI/자동화 → **fan out**
- 대화 중 몇 건의 조사/검증을 위임하고 바로 후속 작업 → **subagent**

### 비대화형 모드

```bash
claude -p "이 프로젝트가 무엇을 하는지 설명하세요"
claude -p "모든 API 엔드포인트 나열" --output-format json
claude -p "로그 파일 분석" --output-format stream-json
claude --permission-mode auto -p "fix all lint errors"
```

### 인터뷰 패턴

```
[기능]을 빌드하고 싶습니다. AskUserQuestion 도구를 사용하여
자세히 인터뷰해주세요. 기술 구현, UI/UX, 엣지 케이스,
트레이드오프에 대해 질문하세요. 완료되면 SPEC.md에 사양을 작성하세요.
```

## 일반적인 실패 패턴

| 패턴 | 문제 | 해결 |
| --- | --- | --- |
| 주방 싱크 세션 | 관련 없는 작업이 context를 오염시킨다 | 작업 간 `/clear` |
| 반복 수정 | 실패한 접근 방식이 context에 누적된다 | 2회 실패 후 `/clear`하고 더 나은 프롬프트로 재시작 |
| 과도한 CLAUDE.md | 중요한 규칙이 노이즈에 묻힌다 | 무자비하게 정리. 불필요한 것은 삭제하거나 hook으로 전환 |
| 신뢰-검증 간격 | 그럴듯하지만 엣지 케이스 미처리 | 항상 검증(테스트, 스크립트, 스크린샷) 제공 |
| 무한 탐색 | 범위 없는 조사로 context 소진 | 범위를 좁히거나 subagent 사용 |
