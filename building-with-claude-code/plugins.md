# 플러그인 만들기

> 원본: [플러그인 만들기](https://code.claude.com/docs/ko/plugins)

## 기본 개념

- **플러그인**: skills, agents, hooks, MCP servers를 패키징하여 Claude Code를 확장하는 단위
- **독립 실행형 구성** (`.claude/` 디렉토리): 개인/프로젝트별 사용, 짧은 skill 이름 (`/hello`)
- **플러그인** (`.claude-plugin/plugin.json`): 팀/커뮤니티 공유, 버전 관리, 네임스페이스 skill 이름 (`/plugin-name:hello`)

| 접근 방식 | Skill 이름 | 최적 용도 |
| :--- | :--- | :--- |
| **독립 실행형** (`.claude/`) | `/hello` | 개인 워크플로우, 프로젝트별 사용, 빠른 실험 |
| **플러그인** (`.claude-plugin/`) | `/plugin-name:hello` | 팀 공유, 커뮤니티 배포, 버전 관리, 프로젝트 간 재사용 |

## 플러그인 구조

```text
my-plugin/
├── .claude-plugin/
│   └── plugin.json          # 매니페스트 (메타데이터 정의)
├── commands/                # Markdown 파일로서의 Skills
├── agents/                  # 사용자 정의 agent 정의
├── skills/                  # SKILL.md 파일이 있는 Agent Skills
├── hooks/                   # hooks.json의 이벤트 핸들러
├── .mcp.json                # MCP server 구성
├── .lsp.json                # LSP server 구성
└── settings.json            # 플러그인 활성화 시 적용되는 기본 설정
```

> `.claude-plugin/` 내에는 `plugin.json`만 들어간다. 다른 모든 디렉토리는 플러그인 루트에 배치한다.

## 옵션

### 매니페스트 (`plugin.json`) 필수 필드

| 필드 | 설명 | 예시 |
| :--- | :--- | :--- |
| `name` | 고유 식별자, skill 네임스페이스로 사용 | `"my-plugin"` |
| `description` | 플러그인 관리자에 표시되는 설명 | `"A greeting plugin"` |
| `version` | 시맨틱 버전 | `"1.0.0"` |
| `author` | 작성자 정보 (선택) | `{"name": "Your Name"}` |

### settings.json

| 키 | 설명 | 비고 |
| :--- | :--- | :--- |
| `agent` | 주 스레드로 활성화할 사용자 정의 agent | 현재 유일하게 지원되는 키 |

## 사용 예시

### 1. 매니페스트 생성

```json
{
  "name": "my-first-plugin",
  "description": "A greeting plugin to learn the basics",
  "version": "1.0.0",
  "author": {
    "name": "Your Name"
  }
}
```

### 2. Skill 정의 (인수 없음)

```markdown
---
description: Greet the user with a friendly message
disable-model-invocation: true
---

Greet the user warmly and ask how you can help them today.
```

### 3. Skill 정의 (인수 포함)

`$ARGUMENTS` 자리 표시자로 사용자 입력을 캡처한다.

```markdown
---
description: Greet the user with a personalized message
---

# Hello Skill

Greet the user named "$ARGUMENTS" warmly and ask how you can help them today. Make the greeting personal and encouraging.
```

### 4. 로컬 테스트

```bash
# 단일 플러그인 로드
claude --plugin-dir ./my-plugin

# 여러 플러그인 동시 로드
claude --plugin-dir ./plugin-one --plugin-dir ./plugin-two
```

실행 후 `/plugin-name:skill-name`으로 skill을 호출한다. 변경 사항 적용 시 `/reload-plugins`를 실행한다.

### 5. LSP server 구성

```json
{
  "go": {
    "command": "gopls",
    "args": ["serve"],
    "extensionToLanguage": {
      ".go": "go"
    }
  }
}
```

### 6. Hooks 구성

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [{ "type": "command", "command": "jq -r '.tool_input.file_path' | xargs npm run lint:fix" }]
      }
    ]
  }
}
```

## 기존 구성을 플러그인으로 변환

| 독립 실행형 (`.claude/`) | 플러그인 |
| :--- | :--- |
| 한 프로젝트에서만 사용 가능 | 마켓플레이스를 통해 공유 가능 |
| `.claude/commands/`의 파일 | `plugin-name/commands/`의 파일 |
| `settings.json`의 Hooks | `hooks/hooks.json`의 Hooks |
| 공유하려면 수동으로 복사 | `/plugin install`로 설치 |

마이그레이션 순서:
1. 플러그인 디렉토리 및 매니페스트 생성
2. 기존 commands, agents, skills 복사
3. hooks를 `hooks/hooks.json`으로 이동
4. `claude --plugin-dir ./my-plugin`으로 테스트
5. 마켓플레이스를 통해 배포
