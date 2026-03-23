# 플러그인 발견 및 설치

> 원본: [마켓플레이스를 통해 미리 빌드된 플러그인 발견 및 설치](https://code.claude.com/docs/ko/discover-plugins)

## 기본 개념

- **플러그인**: Claude Code를 skills, agents, hooks, MCP servers로 확장하는 패키지
- **마켓플레이스**: 플러그인을 검색·설치할 수 있는 카탈로그. 앱 스토어와 유사한 개념
- **설치 흐름**: 마켓플레이스 추가 → 개별 플러그인 설치 (2단계)
- **공식 마켓플레이스**(`claude-plugins-official`): Claude Code 시작 시 자동으로 사용 가능
- **버전 요구사항**: Claude Code **1.0.33 이상** 필요
- **보안 주의**: 신뢰할 수 있는 소스에서만 플러그인을 설치한다. 플러그인은 시스템에서 코드를 실행할 수 있다.

### 설치 범위

| 범위 | 설명 |
|------|------|
| User | 모든 프로젝트에서 자신을 위해 설치 (기본값) |
| Project | 해당 저장소의 모든 협력자를 위해 설치 (`.claude/settings.json`에 추가) |
| Local | 해당 저장소에서만 자신을 위해 설치 (공유 안 됨) |
| Managed | 관리자가 관리되는 설정을 통해 설치 (수정 불가) |

### 공식 마켓플레이스 플러그인 카테고리

| 카테고리 | 주요 플러그인 | 설명 |
|----------|-------------|------|
| 코드 인텔리전스 | `typescript-lsp`, `pyright-lsp`, `rust-analyzer-lsp` 등 | LSP 기반 자동 진단·코드 네비게이션 |
| 외부 통합 | `github`, `gitlab`, `slack`, `linear`, `sentry`, `atlassian`, `notion`, `figma` 등 | MCP servers를 통한 외부 서비스 연결 |
| 개발 워크플로우 | `commit-commands`, `pr-review-toolkit`, `plugin-dev`, `agent-sdk-dev` 등 | Git 워크플로우·PR 리뷰·플러그인 개발·Agent SDK 도구 |
| 출력 스타일 | `explanatory-output-style`, `learning-output-style` | Claude 응답 스타일 커스터마이징 |

## 옵션

### 마켓플레이스 소스 유형

| 소스              | 형식                     | 예시                                              |
| --------------- | ---------------------- | ----------------------------------------------- |
| GitHub          | `owner/repo`           | `anthropics/claude-code`                        |
| Git URL (HTTPS) | 전체 URL                 | `https://gitlab.com/company/plugins.git`        |
| Git URL (SSH)   | SSH URL                | `git@gitlab.com:company/plugins.git`            |
| Git + 특정 ref    | URL`#ref`              | `https://gitlab.com/company/plugins.git#v1.0.0` |
| 로컬 경로           | 디렉토리 또는 파일 경로          | `./my-marketplace`                              |
| 원격 URL          | `marketplace.json` URL | `https://example.com/marketplace.json`          |

### 코드 인텔리전스 지원 언어

| 언어 | 플러그인 | 필요한 바이너리 |
|------|---------|----------------|
| C/C++ | `clangd-lsp` | `clangd` |
| C# | `csharp-lsp` | `csharp-ls` |
| Go | `gopls-lsp` | `gopls` |
| Java | `jdtls-lsp` | `jdtls` |
| Kotlin | `kotlin-lsp` | `kotlin-language-server` |
| Lua | `lua-lsp` | `lua-language-server` |
| PHP | `php-lsp` | `intelephense` |
| Python | `pyright-lsp` | `pyright-langserver` |
| Rust | `rust-analyzer-lsp` | `rust-analyzer` |
| Swift | `swift-lsp` | `sourcekit-lsp` |
| TypeScript | `typescript-lsp` | `typescript-language-server` |

### 자동 업데이트 환경 변수

| 변수 | 설명 |
|------|------|
| `DISABLE_AUTOUPDATER` | Claude Code 및 플러그인 자동 업데이트 모두 비활성화 |
| `FORCE_AUTOUPDATE_PLUGINS=true` | `DISABLE_AUTOUPDATER`와 함께 사용 시 플러그인 자동 업데이트만 유지 |

## 사용 예시

### 마켓플레이스 추가

```shell
# GitHub 저장소에서 추가
/plugin marketplace add anthropics/claude-code

# Git URL에서 추가 (HTTPS)
/plugin marketplace add https://gitlab.com/company/plugins.git

# 특정 브랜치/태그 지정
/plugin marketplace add https://gitlab.com/company/plugins.git#v1.0.0

# 로컬 경로에서 추가
/plugin marketplace add ./my-marketplace
```

### 플러그인 설치·관리

```shell
# 공식 마켓플레이스에서 설치
/plugin install plugin-name@claude-plugins-official

# 특정 범위로 설치
claude plugin install formatter@your-org --scope project

# 비활성화 (제거하지 않음)
/plugin disable plugin-name@marketplace-name

# 다시 활성화
/plugin enable plugin-name@marketplace-name

# 완전히 제거
/plugin uninstall plugin-name@marketplace-name
```

### 마켓플레이스 관리

```shell
# 마켓플레이스 목록 확인
/plugin marketplace list

# 플러그인 목록 새로 고침
/plugin marketplace update marketplace-name

# 마켓플레이스 제거 (설치된 플러그인도 함께 제거됨)
/plugin marketplace remove marketplace-name
```

> 단축 명령: `marketplace` → `market`, `remove` → `rm`으로 축약 가능.

### 플러그인 변경 사항 즉시 적용

```shell
/reload-plugins
```

> LSP 서버가 추가·업데이트된 경우 `/reload-plugins`로는 반영되지 않으며, Claude Code 재시작이 필요하다.

### 팀 마켓플레이스 설정 (`.claude/settings.json`)

```json
{
  "extraKnownMarketplaces": {
    "my-team-tools": {
      "source": {
        "source": "github",
        "repo": "your-org/claude-plugins"
      }
    }
  }
}
```

### 플러그인 캐시 초기화

```shell
rm -rf ~/.claude/plugins/cache
```
