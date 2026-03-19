# Claude Code의 작동 방식
> https://code.claude.com/docs/ko/how-claude-code-works

Claude Code는 터미널에서 실행되는 에이전트 어시스턴트다. 코딩에 탁월하지만 명령줄에서 할 수 있는 모든 작업을 도와준다: 문서 작성, 빌드 실행, 파일 검색, 주제 조사 등.

---

## 1. 에이전트 루프 (Agent Loop)

Claude에게 작업을 주면 **컨텍스트 수집 → 작업 수행 → 결과 검증** 세 단계를 거치며, 전반적으로 도구를 사용한다.

![에이전트 루프](Assets/agentic-loop.svg)

- **루프는 작업에 맞게 조정된다.** 코드베이스 질문은 컨텍스트 수집만, 버그 수정은 세 단계를 반복, 리팩토링은 광범위한 검증을 포함할 수 있다.
- **사용자도 루프의 일부다.** 언제든 중단하여 방향 유도, 추가 컨텍스트 제공, 다른 접근 방식 요청이 가능하다.
- **두 가지 구성 요소로 구동된다:** 추론하는 **모델**과 작용하는 **도구**. Claude Code는 이 둘을 연결하는 에이전트 하네스 역할을 한다.

### 모델

Claude Code는 Claude 모델을 사용하여 코드를 이해하고 작업에 대해 추론한다. 모든 언어의 코드를 읽을 수 있고, 구성 요소 간 연결을 이해하며, 복잡한 작업은 단계로 나누어 실행하고 조정한다.

- **Sonnet**: 대부분의 코딩 작업에 적합
- **Opus**: 복잡한 아키텍처 결정에 더 강력한 추론을 제공
- 세션 중 `/model`로 전환하거나 `claude --model <name>`으로 시작할 수 있다.

> 자세한 내용은 [모델 구성-공식문서](https://code.claude.com/docs/ko/model-config) 참고

### 도구

도구는 Claude Code를 에이전트로 만드는 핵심이다. 도구가 없으면 텍스트로만 응답하지만, 도구가 있으면 코드를 읽고, 파일을 편집하고, 명령을 실행하고, 웹을 검색하고, 외부 서비스와 상호작용할 수 있다. 각 도구 사용 결과는 루프에 피드백되어 다음 결정을 알린다.

내장 도구는 5가지 범주로 나뉜다:

| 범주 | 기능 |
|------|------|
| **파일 작업** | 파일 읽기, 코드 편집, 새 파일 생성, 이름 변경 및 재구성 |
| **검색** | 패턴으로 파일 찾기, 정규식으로 콘텐츠 검색, 코드베이스 탐색 |
| **실행** | 셸 명령 실행, 서버 시작, 테스트 실행, git 사용 |
| **웹** | 웹 검색, 문서 가져오기, 오류 메시지 조회 |
| **코드 인텔리전스** | 편집 후 타입 오류 및 경고 확인, 정의로 이동, 참조 찾기([코드 인텔리전스 플러그인](https://code.claude.com/docs/ko/discover-plugins#code-intelligence) 필요) |

이 외에도 subagents 생성, 질문, 오케스트레이션 등의 도구가 있다. 전체 목록은 [Claude가 사용할 수 있는 도구](https://code.claude.com/docs/ko/settings#tools-available-to-claude) 참고.

Claude는 프롬프트와 그 과정에서 배운 내용을 바탕으로 사용할 도구를 선택한다. 예를 들어 "실패한 테스트를 수정해"라고 하면:

1. 테스트 스위트를 실행하여 무엇이 실패하는지 확인
2. 오류 출력 읽기
3. 관련 소스 파일 검색
4. 해당 파일을 읽어 코드 이해
5. 파일을 편집하여 문제 수정
6. 테스트를 다시 실행하여 검증

각 도구 사용은 다음 단계를 알리는 새로운 정보를 제공한다. 이것이 에이전트 루프의 작동 방식이다.

**기본 기능 확장:** 내장 도구는 기초다. [skills](https://code.claude.com/docs/ko/skills)로 Claude가 아는 것을 확장하고, [MCP](https://code.claude.com/docs/ko/mcp)로 외부 서비스에 연결하고, [hooks](https://code.claude.com/docs/ko/hooks)로 워크플로우를 자동화하고, [subagents](https://code.claude.com/docs/ko/sub-agents)로 작업을 위임할 수 있다. 이러한 확장은 핵심 에이전트 루프 위에 계층을 형성한다.
> 필요에 맞는 확장을 선택하는 방법은 [Claude Code 확장](https://code.claude.com/docs/ko/features-overview)을 참조

---

## 2. Claude가 접근할 수 있는 것

디렉토리에서 `claude`를 실행하면 다음에 접근할 수 있다:

- **프로젝트 파일** - 디렉토리 및 하위 디렉토리의 파일, 허가받은 다른 곳의 파일
- **터미널** - 명령줄에서 할 수 있는 것이면 Claude도 할 수 있다 (빌드 도구, git, 패키지 관리자 등)
- **git 상태** - 현재 브랜치, 커밋되지 않은 변경 사항, 최근 커밋 기록
- **[CLAUDE.md](https://code.claude.com/docs/ko/memory)** - 프로젝트별 지침과 규칙을 저장하는 마크다운 파일. 매 세션마다 로드된다.
- **[자동 메모리](https://code.claude.com/docs/ko/memory#auto-memory)** - 작업하면서 자동 저장하는 학습 내용 (프로젝트 패턴, 사용자 선호도 등). MEMORY.md 처음 200줄이 세션 시작 시 로드된다.
- **구성한 확장** - 외부 서비스를 위한 [MCP servers](https://code.claude.com/docs/ko/mcp), 워크플로우를 위한 [skills](https://code.claude.com/docs/ko/skills), 작업 위임을 위한 [subagents](https://code.claude.com/docs/ko/sub-agents), 브라우저 상호작용을 위한 [Claude in Chrome](https://code.claude.com/docs/ko/chrome)

전체 프로젝트를 보기 때문에 여러 파일에 걸친 조정된 편집이 가능하다. 현재 파일만 보는 인라인 코드 어시스턴트와 다르다.

---

## 3. 실행 환경 및 인터페이스

### 실행 환경

세 가지 환경에서 실행되며, 각각 코드 실행 위치와 장단점이 다르다.

| 환경 | 코드 실행 위치 | 사용 사례 |
|------|-------------|----------|
| **로컬** | 사용자 머신 | 기본값. 파일, 도구, 환경에 대한 전체 접근 |
| **클라우드** | Anthropic 관리 VM | 작업 오프로드, 로컬에 없는 리포지토리에서 작업 |
| **원격 제어** | 사용자 머신, 브라우저에서 제어 | 웹 UI를 사용하면서 모든 것을 로컬로 유지 |

### 인터페이스

터미널, [데스크톱 앱](https://code.claude.com/docs/ko/desktop), [IDE 확장](https://code.claude.com/docs/ko/ide-integrations), [claude.ai/code](https://claude.ai/code), [원격 제어](https://code.claude.com/docs/ko/remote-control), [Slack](https://code.claude.com/docs/ko/slack), [CI/CD 파이프라인](https://code.claude.com/docs/ko/github-actions)을 통해 접근 가능하다. 인터페이스는 달라도 기본 에이전트 루프는 동일하다.

---

## 4. 세션 관리

Claude Code는 작업하면서 대화를 로컬에 저장한다. 각 메시지, 도구 사용, 결과가 저장되어 되돌리기, 재개, 포크가 가능하다. 코드 변경 전 영향 받는 파일의 스냅샷을 만들어 필요 시 되돌릴 수 있다.

### 세션 기본 개념

- **세션은 독립적이다**: 각 새 세션은 이전 대화 기록 없이 새로운 컨텍스트 윈도우로 시작한다.
- [자동 메모리](https://code.claude.com/docs/ko/memory#auto-memory)와 [CLAUDE.md](https://code.claude.com/docs/ko/memory)를 통해 세션 간 학습을 유지할 수 있다.

### 브랜치 간 작업

- 각 세션은 현재 디렉토리에 연결된다. 재개 시 해당 디렉토리의 세션만 표시된다.
- 브랜치를 전환하면 새 브랜치의 파일을 보지만, 대화 기록은 유지된다.
- [git worktrees](https://code.claude.com/docs/ko/common-workflows#run-parallel-claude-code-sessions-with-git-worktrees)로 개별 브랜치에 별도 디렉토리를 만들어 병렬 세션을 실행할 수 있다.

### 세션 재개 및 포크
![session-continuity](Assets/session-continuity.svg)

- **재개**: `claude --continue` 또는 `claude --resume` - 중단한 지점부터 계속한다. 대화 기록은 복원되지만 세션 범위 권한은 복원되지 않는다.
- **포크**: `claude --continue --fork-session` - 대화 기록을 유지하면서 새 세션 ID를 만든다. 원본 세션은 변경되지 않는다.

> 여러 터미널에서 동일한 세션을 재개하면 메시지가 인터리브된다. 병렬 작업에는 `--fork-session`을 사용한다.

### 컨텍스트 윈도우

대화 기록, 파일 콘텐츠, 명령 출력, CLAUDE.md, skills, 시스템 지침을 보유한다.

**컨텍스트가 가득 찰 때:**
- 자동으로 오래된 도구 출력을 지우고, 필요하면 대화를 요약한다.
- 요청과 주요 코드 스니펫은 유지되지만 대화 초반의 지침이 손실될 수 있다.
- 지속적인 규칙은 CLAUDE.md에 넣어야 압축 중 손실을 방지할 수 있다.
- CLAUDE.md에 "Compact Instructions" 섹션을 추가하거나 `/compact`를 포커스와 함께 실행한다 (예: `/compact focus on the API changes`).
- `/context`로 사용량 확인, `/mcp`로 서버별 컨텍스트 비용을 확인할 수 있다.

**skills 및 subagents로 컨텍스트 관리:**
- **Skills**는 요청 시 로드된다. 수동 호출용은 `disable-model-invocation: true`로 필요할 때까지 컨텍스트 밖에 유지할 수 있다.
- **Subagents**는 별도 컨텍스트를 가져 메인 컨텍스트 부풀림을 방지한다. 완료 시 요약만 반환한다.

---

## 5. 안전 메커니즘

### 체크포인트로 변경 취소

- 파일 편집 전 자동 스냅샷을 생성한다.
- `Esc` 두 번으로 이전 상태를 복원할 수 있다.
- 체크포인트는 세션에 로컬이며 git과 분리되어 있다.
- 외부 시스템(DB, API, 배포)에는 적용 불가 → Claude는 외부 부작용 있는 명령 실행 전 승인을 요청한다.

### 권한 모드 (`Shift+Tab`으로 전환)

| 모드 | 설명 |
|------|------|
| **기본값** | 파일 편집 및 셸 명령 전에 승인을 요청한다 |
| **자동 수락 편집** | 파일 편집은 자동, 명령은 승인 필요 |
| **계획 모드** | 읽기 전용 도구만 사용, 실행 전 계획을 승인한다 |

`.claude/settings.json`에서 `npm test`, `git status` 같은 신뢰할 수 있는 명령을 허용 목록에 추가할 수 있다.

---

## 6. 효과적인 사용 팁

### 대화형으로 사용

완벽한 프롬프트가 필요하지 않다. 원하는 것으로 시작한 다음 반복하며 개선하면 된다. 첫 번째 시도가 맞지 않으면 수정 사항을 입력하면 된다.

### 처음부터 구체적으로

특정 파일을 참조하고, 제약 조건을 언급하고, 예제 패턴을 지적한다:

```
체크아웃 흐름이 만료된 카드를 가진 사용자에게 손상되었다.
문제를 찾기 위해 src/payments/를 확인한다. 특히 토큰 새로고침.
먼저 실패하는 테스트를 작성한 다음 수정한다.
```

### 검증 수단 제공

테스트 케이스를 포함하고, 스크린샷을 붙여넣거나, 예상 출력을 정의한다:

```
validateEmail을 구현한다. 테스트 케이스: 'user@example.com' → true,
'invalid' → false, 'user@.com' → false. 후에 테스트를 실행한다.
```

### 탐색 후 구현

복잡한 문제는 연구와 코딩을 분리한다. 계획 모드(`Shift+Tab`)로 먼저 분석 → 계획 검토 → 구현.

### 지시하지 말고 위임

세부 지시보다 컨텍스트와 방향만 제공한다. 읽을 파일이나 실행할 명령을 지정할 필요 없이 Claude가 파악한다.

### 유용한 내장 명령

- `/init` - 프로젝트를 위한 CLAUDE.md 생성 안내
- `/agents` - 사용자 정의 subagents 구성
- `/doctor` - 설치의 일반적인 문제 진단
