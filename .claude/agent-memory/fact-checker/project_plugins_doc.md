---
name: plugins.md 팩트체크 결과 (2026-03-22)
description: building-with-claude-code/plugins.md 대 공식 문서 검증 결과 요약
type: project
---

검토한 문서: `/Users/yjc/Workspace/claude-lab-yjc/building-with-claude-code/plugins.md`
원본 URL: https://code.claude.com/docs/ko/plugins
검토일: 2026-03-22

## 주요 오류 발견

1. **SKILL.md 프론트매터 `name` 기본값**: 로컬 문서는 `name` 필드의 기본값을 "폴더명"이라고 기술하지만, 원본에서 이를 명시하는 부분이 없음. 확인 불가능한 정보.

2. **인수 포함 Skill 예시 코드 불완전**: 원본의 인수 포함 SKILL.md 예시는 `"Make the greeting personal and encouraging."` 문장이 포함되어 있으나 로컬 문서에서 해당 문장이 생략됨.

## 누락된 주요 정보

- **필수 버전 요구사항**: Claude Code 버전 1.0.33 이상 필요 (원본에는 명시됨)
- **settings.json 우선순위**: `settings.json` 설정이 `plugin.json`에 선언된 `settings`보다 우선함, 알 수 없는 키는 자동 무시
- **LSP server 재시작 필요**: LSP 구성 변경 시 `/reload-plugins`가 아닌 전체 재시작 필요
- **플러그인 공식 마켓플레이스 제출 링크**: claude.ai/settings/plugins/submit, platform.claude.com/plugins/submit

## 확인된 정확한 내용
- 플러그인 vs 독립 실행형 비교표 정확
- 매니페스트 plugin.json 필수 필드 4개 정확
- 로컬 테스트 명령어 (--plugin-dir 플래그) 정확
- /reload-plugins 명령어 설명 정확
- LSP 구성 예시 (gopls) 정확
- hooks.json 구조 및 예시 정확
- 마이그레이션 비교표 정확
- ".claude-plugin/ 내에는 plugin.json만" 경고 정확

## 패턴 메모
- 이 레포의 요약 문서들은 원본의 코드 예시를 일부 생략하거나 단순화하는 경향이 있음
- 버전 요구사항, 우선순위 동작, 예외 케이스 등 운영 중요 정보가 누락되는 패턴 반복됨

**Why:** 공식 문서와의 불일치를 향후 검토 시 빠르게 참조하기 위해 기록
**How to apply:** 이 문서의 후속 팩트체크나 수정 요청 시 참조
