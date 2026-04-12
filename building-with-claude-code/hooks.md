# Hooks

> 원본: [https://code.claude.com/docs/ko/hooks](https://code.claude.com/docs/ko/hooks), [https://code.claude.com/docs/ko/hooks-guide](https://code.claude.com/docs/ko/hooks-guide)

## 기본 개념

- Hook은 Claude Code 세션의 특정 시점에 자동 실행되는 셸 명령, HTTP 엔드포인트, LLM 프롬프트, 에이전트이다.
- 설정 위치: `~/.claude/settings.json`(사용자), `.claude/settings.json`(프로젝트), `.claude/settings.local.json`(로컬), 관리 정책, 플러그인, 컴포넌트 프론트매터
- Hook 타입: `command`, `http`, `prompt`, `agent`

### 라이프사이클

![Hook 라이프사이클](Assets/hooks-lifecycle.svg)

```
SessionStart → InstructionsLoaded → UserPromptSubmit
→ PreToolUse → PermissionRequest → PostToolUse / PostToolUseFailure
→ Notification, CwdChanged, FileChanged, ConfigChange (반응형)
→ SessionEnd
```

### 종료 코드

| 종료 코드 | 동작 |
|-----------|------|
| 0 | 성공. JSON 출력 처리 |
| 2 | 차단 오류. stderr가 사용자/Claude에게 표시 |
| 기타 | 비차단 오류. verbose 모드에서만 표시 |

### Hook 해석 흐름

![Hook 해석 흐름](Assets/hook-resolution.svg)

## 설정 구조

```json
{
  "hooks": {
    "EventName": [
      {
        "matcher": "필터_패턴",
        "hooks": [
          {
            "type": "command|http|prompt|agent",
            "if": "ToolName(pattern)",
            "timeout": 600,
            "statusMessage": "커스텀 메시지"
          }
        ]
      }
    ]
  }
}
```

## 옵션

### 공통 필드

| 옵션 | 설명 | 기본값 |
|------|------|--------|
| `type` | Hook 타입 (`command`, `http`, `prompt`, `agent`) | 필수 |
| `if` | 권한 규칙 구문으로 필터링 (도구 이벤트 전용) | - |
| `timeout` | 취소까지 대기 시간(초) | command: 600, prompt: 30, agent: 60 |
| `statusMessage` | 실행 중 표시할 스피너 메시지 | - |

### Hook 타입별 옵션

**Command Hook**

| 옵션 | 설명 | 기본값 |
|------|------|--------|
| `command` | 실행할 셸 명령 경로 | 필수 |
| `async` | 백그라운드 실행 여부 | false |
| `shell` | 사용할 셸 | `bash` |

**HTTP Hook**

| 옵션 | 설명 | 기본값 |
|------|------|--------|
| `url` | POST 요청 대상 URL | 필수 |
| `headers` | 커스텀 HTTP 헤더 (환경변수 보간 지원) | - |
| `allowedEnvVars` | 헤더에 허용할 환경변수 목록 | - |

**Prompt Hook**

| 옵션 | 설명 | 기본값 |
|------|------|--------|
| `prompt` | LLM에 전달할 프롬프트 | 필수 |
| `model` | 사용할 모델 | - |

**Agent Hook**

| 옵션 | 설명 | 기본값 |
|------|------|--------|
| `prompt` | 서브에이전트에 전달할 프롬프트 | 필수 |
| `model` | 사용할 모델 (`sonnet` 등) | - |

### `if` 필드로 세부 필터링

> v2.1.85 이상 필요. 이전 버전에서는 무시된다.

`matcher`는 그룹 수준에서 도구 이름만으로 필터링한다. `if` 필드는 개별 hook 수준에서 권한 규칙 구문을 사용하여 도구 이름 + 인수까지 필터링한다. 조건이 일치할 때만 hook 프로세스가 생성된다.

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "if": "Bash(git *)",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/check-git-policy.sh"
          }
        ]
      }
    ]
  }
}
```

- `if`는 도구 이벤트에서만 동작한다: `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest`, `PermissionDenied`
- 여러 도구를 일치시키려면 각각 별도 핸들러를 사용하거나 `matcher` 수준에서 파이프(`|`)로 일치시킨다.

### Matcher 패턴

| 이벤트                           | 매칭 대상     | 예시                                                                                 |
| ----------------------------- | --------- | ---------------------------------------------------------------------------------- |
| Tool 이벤트                      | 도구 이름     | `Bash`, `Edit\|Write`, `mcp__.*`                                                   |
| SessionStart                  | 세션 소스     | `startup`, `resume`, `clear`, `compact`                                            |
| SessionEnd                    | 종료 사유     | `clear`, `resume`, `logout`, `prompt_input_exit`                                   |
| Notification                  | 알림 타입     | `permission_prompt`, `idle_prompt`                                                 |
| SubagentStart/Stop            | 에이전트 타입   | `Bash`, `Explore`, `Plan`                                                          |
| ConfigChange                  | 설정 소스     | `user_settings`, `project_settings`, `local_settings`, `policy_settings`, `skills` |
| FileChanged                   | 파일명 패턴    | `.envrc`, `.env`                                                                   |
| StopFailure                   | 오류 타입     | `rate_limit`, `authentication_failed`, `billing_error`                             |
| PreCompact/PostCompact        | 압축 트리거    | `manual`, `auto`                                                                   |
| InstructionsLoaded            | 로드 사유     | `session_start`, `nested_traversal`, `include`, `path_glob_match`, `compact`       |
| Elicitation/ElicitationResult | MCP 서버 이름 | 설정된 MCP 서버명                                                                        |
| UserPromptSubmit, Stop, TeammateIdle, TaskCreated, TaskCompleted, WorktreeCreate, WorktreeRemove, CwdChanged | matcher 미지원 | 모든 발생에서 항상 실행 |

## JSON 입력 형식

모든 이벤트에 공통으로 전달되는 입력 필드:

| 필드 | 설명 |
|------|------|
| `session_id` | 현재 세션 ID |
| `transcript_path` | 대화 기록 파일 경로 |
| `cwd` | 현재 작업 디렉토리 |
| `permission_mode` | 권한 모드 (`default`, `plan`, `acceptEdits`, `auto`, `dontAsk`, `bypassPermissions`) |
| `hook_event_name` | 이벤트 이름 |
| `agent_id` | 서브에이전트 ID (해당 시) |
| `agent_type` | 에이전트 타입 (해당 시) |

### 이벤트별 추가 입력

| 이벤트                             | 추가 필드                                                                       |
| ------------------------------- | --------------------------------------------------------------------------- |
| `PreToolUse` / `PostToolUse`    | `tool_name`, `tool_input`, `tool_use_id`                                    |
| `PostToolUseFailure`            | `tool_input`, `error`, `is_interrupt`                                       |
| `PermissionRequest`             | `tool_name`, `tool_input`, `permission_suggestions`                         |
| `PermissionDenied`              | `tool_name`, `tool_input`, `reason`                                         |
| `UserPromptSubmit`              | `prompt`                                                                    |
| `Stop` / `SubagentStop`         | `stop_hook_active`, `last_assistant_message`                                |
| `SessionStart`                  | `source`, `model`, `agent_type`                                             |
| `CwdChanged`                    | `old_cwd`, `new_cwd`                                                        |
| `FileChanged`                   | `file_path`, `event`                                                        |
| `TaskCreated` / `TaskCompleted` | `task_id`, `task_subject`, `task_description`, `teammate_name`, `team_name` |
| `InstructionsLoaded`            | `file_path`, `memory_type`, `load_reason`, `globs`, `trigger_file_path`     |
| `PostToolUse` (추가)              | `tool_response`                                                             |

## JSON 출력 형식

Hook이 반환할 수 있는 JSON 필드:

| 필드 | 설명 |
|------|------|
| `continue` | `false`이면 Claude 완전 중지 |
| `stopReason` | 중지 사유 |
| `suppressOutput` | 출력 숨기기 |
| `systemMessage` | 사용자에게 표시할 경고 메시지 |
| `decision` | `"block"`으로 도구 호출 차단 |
| `reason` | 차단 사유 |

### PreToolUse 전용 출력

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "allow|deny|ask|defer",
    "permissionDecisionReason": "...",
    "updatedInput": { "modified_field": "value" },
    "additionalContext": "..."
  }
}
```

- `allow`: 권한 프롬프트 없이 진행. 단, 설정의 거부 규칙이 일치하면 hook이 `allow`를 반환해도 차단된다.
- `deny`: 도구 호출을 취소하고 이유를 Claude에 전달.
- `ask`: 사용자에게 권한 프롬프트를 표시.

### PermissionRequest 전용 출력

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PermissionRequest",
    "decision": {
      "behavior": "allow",
      "updatedPermissions": [
        { "type": "setMode", "mode": "acceptEdits", "destination": "session" }
      ]
    }
  }
}
```

- `behavior`: `"allow"` 반환 시 권한 대화를 건너뛴다.
- `updatedPermissions`: 세션 권한 모드를 변경할 수 있다. `mode`는 `default`, `acceptEdits`, `bypassPermissions` 등.
- Hook 경로는 현재 대화를 유지한다. 컨텍스트를 지우고 새 세션을 시작할 수 없다.

## Hook 타입별 동작

### Prompt Hook

셸 명령 대신 Claude 모델(기본 Haiku)에 프롬프트와 입력 데이터를 전송하여 판단을 위임한다. 결정론적 규칙이 아닌 판단이 필요한 경우에 사용한다.

- 응답 형식: `{"ok": true}` (진행) 또는 `{"ok": false, "reason": "사유"}` (차단)
- `"ok": false` 시 `reason`이 Claude에 피드백으로 전달된다.
- `model` 필드로 다른 모델을 지정할 수 있다.

```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "prompt",
            "prompt": "Check if all tasks are complete. If not, respond with {\"ok\": false, \"reason\": \"what remains to be done\"}."
          }
        ]
      }
    ]
  }
}
```

### Agent Hook

파일 읽기, 코드 검색, 명령 실행 등 도구 액세스가 가능한 서브에이전트를 생성한다. 코드베이스의 실제 상태를 확인해야 할 때 사용한다.

- 응답 형식: Prompt Hook과 동일 (`"ok"` / `"reason"`)
- 기본 타임아웃: 60초, 최대 50개 도구 사용 턴
- 입력 데이터만으로 결정 가능하면 Prompt Hook, 실제 확인이 필요하면 Agent Hook을 사용한다.

```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "agent",
            "prompt": "Verify that all unit tests pass. Run the test suite and check the results. $ARGUMENTS",
            "timeout": 120
          }
        ]
      }
    ]
  }
}
```

## 충돌 해결

여러 hook이 일치하면 각각 병렬로 실행되고 결과를 반환한다. 결정 충돌 시 가장 제한적인 답변이 우선한다:

- `PreToolUse`에서 하나라도 `deny`를 반환하면 다른 결과와 무관하게 도구 호출이 취소된다.
- 하나가 `ask`를 반환하면 나머지가 `allow`여도 권한 프롬프트가 강제된다.
- `additionalContext` 텍스트는 모든 hook에서 수집되어 Claude에 전달된다.
- 여러 `PreToolUse` hook이 `updatedInput`을 반환하면 마지막으로 완료된 것이 적용된다 (병렬 실행이므로 비결정적).

## Hooks와 권한 모드

- `PreToolUse` hook은 모든 권한 모드 확인 전에 실행된다.
- `permissionDecision: "deny"`를 반환하는 hook은 `bypassPermissions` 모드에서도 도구를 차단한다.
- 반대로 `"allow"`를 반환하는 hook은 설정의 거부 규칙을 우회하지 못한다.
- **hook은 제한을 강화할 수 있지만, 권한 규칙이 허용하는 것을 초과하여 완화할 수 없다.**

## 주요 이벤트 요약

| 이벤트 | 시점 | 주요 용도 |
|--------|------|-----------|
| `SessionStart` | 세션 시작/재개 | 환경 설정, 컨텍스트 주입 |
| `UserPromptSubmit` | 사용자 입력 처리 전 | 입력 검증, 차단 |
| `PreToolUse` | 도구 실행 전 | 권한 제어, 입력 수정 |
| `PermissionRequest` | 권한 대화상자 표시 전 | 자동 허용/거부, 권한 규칙 추가 |
| `PostToolUse` | 도구 성공 후 | 추가 컨텍스트, MCP 출력 수정 |
| `PostToolUseFailure` | 도구 실패 후 | 오류 피드백 |
| `Stop` | Claude 응답 완료 시 | 중지 방지 (`decision: "block"`) |
| `Notification` | 알림 발생 시 | 컨텍스트 추가 가능 |
| `CwdChanged` | 작업 디렉토리 변경 | 파일 감시 경로 업데이트 |
| `FileChanged` | 감시 파일 수정 | 동적 모니터링 |
| `ConfigChange` | 설정 파일 변경 | 변경 차단 가능 |
| `PermissionDenied` | auto 모드 분류기 거부 시 | 재시도 허용 (`retry: true`) |
| `SubagentStart` | 서브에이전트 생성 시 | 컨텍스트 주입 |
| `SubagentStop` | 서브에이전트 종료 시 | 중지 방지 가능 |
| `StopFailure` | API 오류로 턴 종료 시 | 로깅 전용 |
| `TaskCreated` | 태스크 생성 시 | 생성 차단 가능 |
| `TaskCompleted` | 태스크 완료 시 | 완료 차단 가능 |
| `TeammateIdle` | 팀원 유휴 시 | 유휴 방지 가능 |
| `PreCompact` | 컨텍스트 압축 전 | 관찰 전용 |
| `PostCompact` | 컨텍스트 압축 후 | 관찰 전용 |
| `InstructionsLoaded` | CLAUDE.md/rules 로드 시 | 관찰 전용 |
| `WorktreeCreate` | Git worktree 생성 시 | 경로 반환 |
| `WorktreeRemove` | Git worktree 제거 시 | 관찰 전용 |
| `Elicitation` | MCP 서버 사용자 입력 요청 시 | 자동 응답 가능 |
| `ElicitationResult` | 사용자 응답 시 | 응답 재정의 가능 |
| `SessionEnd` | 세션 종료 | 정리 작업 (timeout 1.5초) |

## 사용 예시

### 위험한 명령 차단 (Command Hook)

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "/path/to/block-dangerous.sh"
          }
        ]
      }
    ]
  }
}
```

```bash
# block-dangerous.sh
COMMAND=$(jq -r '.tool_input.command')
if echo "$COMMAND" | grep -q 'rm -rf'; then
  echo "Blocked: dangerous command" >&2
  exit 2
fi
exit 0
```

### 편집 후 코드 자동 포맷 (PostToolUse + Prettier)

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "jq -r '.tool_input.file_path' | xargs npx prettier --write"
          }
        ]
      }
    ]
  }
}
```

### 보호된 파일 편집 차단 (PreToolUse + 스크립트)

`.claude/hooks/protect-files.sh`:

```bash
#!/bin/bash
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

PROTECTED_PATTERNS=(".env" "package-lock.json" ".git/")

for pattern in "${PROTECTED_PATTERNS[@]}"; do
  if [[ "$FILE_PATH" == *"$pattern"* ]]; then
    echo "Blocked: $FILE_PATH matches protected pattern '$pattern'" >&2
    exit 2
  fi
done

exit 0
```

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/protect-files.sh"
          }
        ]
      }
    ]
  }
}
```

### 압축 후 컨텍스트 재주입 (SessionStart + compact)

컨텍스트 윈도우 압축 시 중요한 세부 정보가 손실될 수 있다. `compact` matcher로 압축 후 핵심 컨텍스트를 재주입한다.

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "compact",
        "hooks": [
          {
            "type": "command",
            "command": "echo 'Reminder: use Bun, not npm. Run bun test before committing. Current sprint: auth refactor.'"
          }
        ]
      }
    ]
  }
}
```

### 구성 변경 감사 (ConfigChange)

```json
{
  "hooks": {
    "ConfigChange": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "jq -c '{timestamp: now | todate, source: .source, file: .file_path}' >> ~/claude-config-audit.log"
          }
        ]
      }
    ]
  }
}
```

### 플랫폼별 알림 (Notification)

macOS:

```json
{
  "hooks": {
    "Notification": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "osascript -e 'display notification \"Claude Code needs your attention\" with title \"Claude Code\"'"
          }
        ]
      }
    ]
  }
}
```

Linux: `notify-send 'Claude Code' 'Claude Code needs your attention'`

### 권한 대화 자동 승인 (PermissionRequest)

특정 도구에 대해 권한 대화를 건너뛴다. matcher를 가능한 한 좁게 유지해야 한다.

```json
{
  "hooks": {
    "PermissionRequest": [
      {
        "matcher": "ExitPlanMode",
        "hooks": [
          {
            "type": "command",
            "command": "echo '{\"hookSpecificOutput\": {\"hookEventName\": \"PermissionRequest\", \"decision\": {\"behavior\": \"allow\"}}}'"
          }
        ]
      }
    ]
  }
}
```

### Bash 명령 로깅 (PostToolUse + Bash)

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "jq -r '.tool_input.command' >> ~/.claude/command-log.txt"
          }
        ]
      }
    ]
  }
}
```

### 파일 저장 후 자동 린트 (PostToolUse)

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "/path/to/lint.sh"
          }
        ]
      }
    ]
  }
}
```

### direnv 연동 (CwdChanged)

```json
{
  "hooks": {
    "CwdChanged": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "direnv export bash >> $CLAUDE_ENV_FILE"
          }
        ]
      }
    ]
  }
}
```

### 사용자 입력 검증 (UserPromptSubmit)

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "/path/to/validate-prompt.sh"
          }
        ]
      }
    ]
  }
}
```

```bash
# validate-prompt.sh
PROMPT=$(jq -r '.prompt')
if echo "$PROMPT" | grep -qi 'secret\|password\|credential'; then
  echo "Blocked: 민감 정보가 포함된 프롬프트" >&2
  exit 2
fi
echo '{"additionalContext": "보안 검증 통과"}'
exit 0
```

### 세션 시작 시 환경변수 주입 (SessionStart)

```json
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "echo 'export PROJECT_ENV=production' >> $CLAUDE_ENV_FILE"
          }
        ]
      }
    ]
  }
}
```

### 외부 서비스 알림 (HTTP Hook)

```json
{
  "hooks": {
    "SessionEnd": [
      {
        "hooks": [
          {
            "type": "http",
            "url": "http://localhost:8080/hooks/session-end",
            "headers": {
              "Authorization": "Bearer $HOOK_TOKEN"
            },
            "allowedEnvVars": ["HOOK_TOKEN"]
          }
        ]
      }
    ]
  }
}
```

### 안전성 자동 판단 (Prompt Hook)

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "prompt",
            "prompt": "Is this safe? $ARGUMENTS",
            "model": "haiku"
          }
        ]
      }
    ]
  }
}
```

### 도구 실행 권한 자동 허용 (PreToolUse)

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Read|Glob|Grep",
        "hooks": [
          {
            "type": "command",
            "command": "echo '{\"hookSpecificOutput\":{\"permissionDecision\":\"allow\",\"permissionDecisionReason\":\"읽기 전용 도구 자동 허용\"}}'"
          }
        ]
      }
    ]
  }
}
```

### 응답 완료 방지 (Stop)

```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "/path/to/check-completion.sh"
          }
        ]
      }
    ]
  }
}
```

```bash
# check-completion.sh
# decision: "block"을 반환하면 Claude가 멈추지 않고 계속 작업한다
MESSAGE=$(jq -r '.last_assistant_message')
if echo "$MESSAGE" | grep -q 'TODO'; then
  echo '{"decision":"block","reason":"미완료 TODO가 남아있습니다"}'
fi
exit 0
```

### MCP 도구 필터링 (PreToolUse + matcher)

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "mcp__slack__.*",
        "hooks": [
          {
            "type": "command",
            "command": "/path/to/approve-slack.sh"
          }
        ]
      }
    ]
  }
}
```

### Skills/Agent에서 Hook 정의

프론트매터에서 동일한 구조로 정의한다. 컴포넌트 라이프사이클에 한정된다.

```yaml
---
name: secure-operations
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "./scripts/check.sh"
---
```

## 경로 참조 변수

| 변수                      | 설명                                                                 |
| ----------------------- | ------------------------------------------------------------------ |
| `$CLAUDE_PROJECT_DIR`   | 프로젝트 루트                                                            |
| `${CLAUDE_PLUGIN_ROOT}` | 플러그인 설치 디렉토리                                                       |
| `${CLAUDE_PLUGIN_DATA}` | 플러그인 영속 데이터 디렉토리                                                   |
| `$CLAUDE_ENV_FILE`      | 후속 Bash 명령에 환경변수 전달용 파일 (SessionStart, CwdChanged, FileChanged 전용) |
| `$CLAUDE_CODE_REMOTE`   | 원격 환경에서 `"true"`, 로컬에서 미설정                                         |

## Hook 설정 위치

| 위치 | 범위 | 공유 가능 |
|------|------|----------|
| `~/.claude/settings.json` | 모든 프로젝트 | 아니오, 로컬 |
| `.claude/settings.json` | 단일 프로젝트 | 예, 커밋 가능 |
| `.claude/settings.local.json` | 단일 프로젝트 | 아니오, gitignored |
| 관리형 정책 설정 | 조직 전체 | 예, 관리자 제어 |
| Plugin `hooks/hooks.json` | 플러그인 활성 시 | 예, 플러그인 번들 |
| Skill/Agent 프론트매터 | 컴포넌트 활성 시 | 예, 컴포넌트 파일 정의 |

## Hook 관리

- `/hooks` 명령으로 설정된 Hook을 대화형으로 조회할 수 있다 (읽기 전용).
- 전체 비활성화: 설정 파일에 `"disableAllHooks": true` 추가 (관리 정책 Hook은 제외).
- 설정 파일 편집 시 파일 감시자가 자동으로 변경을 감지한다.

## 제한 사항

- Command hook은 stdout, stderr, 종료 코드로만 통신한다. `/` 명령이나 도구 호출을 직접 트리거할 수 없다.
- Hook 타임아웃: 기본 10분, `timeout` 필드(초)로 hook별 설정 가능.
- `PostToolUse` hook은 도구가 이미 실행된 후이므로 작업을 취소할 수 없다.
- `PermissionRequest` hook은 비대화형 모드(`-p`)에서 발생하지 않는다. 자동화된 권한 결정에는 `PreToolUse`를 사용한다.
- `Stop` hook은 Claude가 응답을 완료할 때마다 발생한다. 사용자 중단 시에는 발생하지 않으며, API 오류는 `StopFailure`를 발생시킨다.
- 여러 `PreToolUse` hook이 `updatedInput`을 반환하면 마지막으로 완료된 것이 적용된다 (병렬 실행이므로 비결정적). 동일 도구의 입력을 수정하는 hook이 두 개 이상 있는 것을 피한다.

## 트러블슈팅

### Hook이 발생하지 않음

- `/hooks`에서 hook이 올바른 이벤트 아래에 나타나는지 확인한다.
- Matcher 패턴은 대소문자를 구분한다.
- 비대화형 모드(`-p`)에서 `PermissionRequest`를 사용 중이라면 `PreToolUse`로 전환한다.

### Stop Hook 무한 루프

JSON 입력의 `stop_hook_active` 필드를 확인하고 `true`이면 조기 종료해야 한다:

```bash
#!/bin/bash
INPUT=$(cat)
if [ "$(echo "$INPUT" | jq -r '.stop_hook_active')" = "true" ]; then
  exit 0  # Claude가 중지되도록 허용
fi
# ... 나머지 로직
```

### JSON 파싱 오류

셸 프로필(`~/.zshrc`, `~/.bashrc`)의 무조건적 `echo` 문이 hook의 JSON 출력에 섞일 수 있다. 대화형 셸에서만 실행되도록 래핑한다:

```bash
# ~/.zshrc 또는 ~/.bashrc
if [[ $- == *i* ]]; then
  echo "Shell ready"
fi
```

### 디버그

- `Ctrl+O`로 verbose 모드를 전환하여 트랜스크립트에서 hook 출력을 확인한다.
- `claude --debug`로 일치한 hook 및 종료 코드를 포함한 전체 실행 세부 정보를 확인한다.
- 수동 테스트: `echo '{"tool_name":"Bash","tool_input":{"command":"ls"}}' | ./my-hook.sh && echo $?`
