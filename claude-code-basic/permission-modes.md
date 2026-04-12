# 권한 모드 선택

> 원본: [권한 모드 선택](https://code.claude.com/docs/ko/permission-modes)

## 기본 개념

- 권한 모드는 Claude가 행동하기 전에 사용자에게 묻는지 여부를 제어한다.
- 작업의 민감도에 따라 완전한 감시, 최소 중단, 읽기 전용 접근 등 다양한 수준의 자율성을 선택할 수 있다.
- 어떤 모드든 보호된 경로에 대한 쓰기는 자동 승인되지 않는다.
  - **보호 디렉토리**: `.git`, `.vscode`, `.idea`, `.husky`, `.claude` (`.claude/commands`, `.claude/agents`, `.claude/skills`, `.claude/worktrees`는 예외)
  - **보호 파일**: `.gitconfig`, `.gitmodules`, `.bashrc`, `.bash_profile`, `.zshrc`, `.zprofile`, `.profile`, `.ripgreprc`, `.mcp.json`, `.claude.json`

## 옵션

| 모드                  | 묻지 않고 수행 가능한 작업                                                           | 최적 사용 사례           |
| :------------------ | :------------------------------------------------------------------------ | :----------------- |
| `default`           | 파일 읽기                                                                     | 시작, 민감한 작업         |
| `acceptEdits`       | 파일 읽기·편집, 일반 파일시스템 명령(`mkdir`, `touch`, `rm`, `rmdir`, `mv`, `cp`, `sed`) | 검토 중인 코드 반복        |
| `plan`              | 파일 읽기 (편집 불가)                                                             | 코드베이스 탐색, 리팩토링 계획  |
| `auto`              | 모든 작업 (백그라운드 안전 검사 포함)                                                    | 장시간 작업, 프롬프트 피로 감소 |
| `bypassPermissions` | 보호된 디렉토리 쓰기 제외 모든 작업                                                      | 격리된 컨테이너·VM 전용     |
| `dontAsk`           | 사전 승인된 도구만                                                                | 잠금된 환경, CI 파이프라인   |

### 권한 접근 방식 비교

|         | `default` | `acceptEdits` | `plan`          | `auto`                | `dontAsk`     | `bypassPermissions` |
| :------ | :-------- | :------------ | :-------------- | :-------------------- | :------------ | :------------------ |
| 권한 프롬프트 | 파일 편집·명령  | 명령·보호 디렉토리    | 파일 편집·명령        | 폴백 전까지 없음             | 없음 (미허용 시 차단) | 보호 디렉토리만            |
| 안전 검사   | 각 작업 검토   | 명령·보호 디렉토리 쓰기 | 각 작업 검토 (편집 차단) | 분류기가 검토, 차단 시 프롬프트 폴백 | 사전 승인 규칙만     | 보호 디렉토리 쓰기만         |
| 토큰 사용   | 표준        | 표준            | 표준              | 높음 (분류기 호출)           | 표준            | 표준                  |

## 사용 예시

### 모드 전환

세션 중 `Shift+Tab`으로 `default` → `acceptEdits` → `plan` 순환한다. 기본 순환에는 `auto`, `bypassPermissions`, `dontAsk`가 포함되지 않는다.

- `auto`: `--enable-auto-mode`로 옵트인하면 순환에 추가된다.
- `bypassPermissions`: `--permission-mode bypassPermissions`, `--dangerously-skip-permissions`, `--allow-dangerously-skip-permissions` 중 하나로 시작하면 순환에 추가된다.
- `dontAsk`: 순환에 포함되지 않으며 `--permission-mode dontAsk`로만 설정한다.

```bash
# 시작 시 모드 지정
claude --permission-mode plan

# 비대화형 모드에서 사용
claude -p "refactor auth" --permission-mode acceptEdits
```

설정 파일에서 기본 모드를 지정할 수도 있다:

```json
{
  "permissions": {
    "defaultMode": "acceptEdits"
  }
}
```

### 계획 모드 (plan)

편집 없이 연구·분석만 수행한다. 프롬프트 앞에 `/plan`을 붙이거나 모드를 전환한다.

```bash
claude --permission-mode plan
```

- Claude가 파일 읽기, 계획 작성은 하지만 소스 코드를 편집하지 않는다. 셸 명령과 네트워크 요청은 default 모드와 동일하게 사용자 승인이 필요하다.
- 계획 완료 후 승인 옵션: 자동 모드로 시작 / 편집 수락 / 수동 검토 / 피드백으로 계속 계획 / Ultraplan으로 정제. 각 승인 옵션에서 계획 컨텍스트 초기화도 선택할 수 있다.

### 자동 모드 (auto)

Team, Enterprise, API 플랜에서 사용 가능하다 (Pro, Max 불가). Claude Sonnet 4.6 또는 Opus 4.6이 필요하다 (Haiku, claude-3 모델 불가). Anthropic API 전용이다 (Bedrock, Vertex, Foundry 불가).

```bash
# 자동 모드로 시작
claude --permission-mode auto

# Shift+Tab 순환 목록에 auto 추가 (다른 모드로 시작 가능)
claude --enable-auto-mode --permission-mode plan
```

- 별도의 분류기 모델(Sonnet 4.6)이 각 작업을 사전 검토한다. 분류기는 사용자 메시지, 도구 호출, CLAUDE.md 내용을 입력으로 받으며, Claude의 응답 텍스트와 도구 실행 결과는 제외된다. 이를 통해 파일이나 웹 페이지에 포함된 악의적 지시가 분류기를 조작하는 것을 방지한다. 별도의 서버 측 프로브가 도구 결과에서 의심스러운 내용을 검사한다.
- 작업 범위 초과, 외부 인프라 대상, 악의적 지시에 의한 작업을 차단한다.

**기본 차단 항목**:
- `curl | bash` 등 코드 다운로드·실행
- 외부 엔드포인트로 민감한 데이터 전송
- 프로덕션 배포·마이그레이션
- 클라우드 스토리지 대량 삭제
- IAM·리포지토리 권한 부여
- 공유 인프라 수정
- 세션 시작 전에 존재하던 파일의 되돌릴 수 없는 삭제
- 강제 푸시, `main` 직접 푸시

**기본 허용 항목**:
- 작업 디렉토리 로컬 파일 작업
- 선언된 종속성 설치
- `.env` 읽기 및 자격 증명을 일치하는 API로 전송
- 읽기 전용 HTTP 요청
- 시작한 분기 또는 Claude가 만든 분기로 푸시
- 샌드박스 네트워크 접근 요청

**폴백**: 연속 3회 또는 세션 총 20회 차단 시 자동 모드가 일시 중지되고 프롬프트 방식으로 복귀한다. 프롬프트된 작업을 승인하면 자동 모드가 재개된다. 허용된 작업은 연속 카운터를 초기화하지만, 총 카운터는 세션 동안 유지된다. 이 임계값은 설정으로 변경할 수 없다.

### dontAsk 모드

명시적으로 허용되지 않은 모든 도구를 자동 거부한다. 완전 비대화형이다.

```bash
claude --permission-mode dontAsk
```

### bypassPermissions 모드

보호된 디렉토리(`.git` 등) 쓰기를 제외한 모든 권한 프롬프트·안전 검사를 비활성화한다. 격리된 환경에서만 사용한다.

```bash
claude --permission-mode bypassPermissions
# 또는
claude --dangerously-skip-permissions
```

`--allow-dangerously-skip-permissions` 플래그는 모드를 활성화하지 않고 `Shift+Tab` 순환 목록에만 추가한다.

### 추가 커스터마이즈

- **권한 규칙**: 설정 파일에 `allow`, `ask`, `deny` 항목을 추가하여 도구·명령별 제어 가능.
- **Hooks**: `PreToolUse` 훅으로 도구 호출 전 허용/거부/확대 로직 구현. `PermissionRequest` 훅으로 권한 대화 가로채기 가능.
