---
name: claude-directory.md 팩트체크 결과
description: 2026-04-04 수행한 claude-directory.md 대비 오류 검토 기록 (설정 우선순위 5단계 누락, CLAUDE.local.md/managed-settings.json 누락, memory:local 저장경로 누락)
type: project
---

2026-04-04, claude-code-basic/claude-directory.md 팩트체크 수행.

**Why:** 원본 https://code.claude.com/docs/en/claude-directory 와의 사실 비교 검증 요청.

**How to apply:** 해당 문서 재검토 시 아래 발견 오류를 참고.

## 발견된 주요 오류

1. **설정 우선순위 누락** (라인 343-353): 한국어 문서는 4단계 우선순위를 기술하지만 원본은 5단계.
   - 누락 항목: `managed settings` (최우선, CLI 플래그로도 오버라이드 불가)
   - 실제 순서 (높은 것이 우선): managed → CLI → settings.local.json → settings.json → ~/.claude/settings.json
   - 특히 한국어 문서는 "CLI 플래그가 최우선"이라고 기술하는데 이는 틀림

2. **CLAUDE.local.md 파일 전혀 미언급**: 원본의 "What's not shown" 섹션에 명시된 파일.
   - 프로젝트 루트에 위치, 수동 생성 후 .gitignore에 등록 필요
   - CLAUDE.md와 함께 로드되는 개인용 파일

3. **managed-settings.json 파일 전혀 미언급**: 원본의 "What's not shown" 섹션에 명시.
   - 엔터프라이즈 배포용 설정, 어떤 것도 오버라이드 불가

4. **memory: local 저장경로 누락** (라인 141): agents frontmatter 테이블에서 memory 필드 값 3종은 나열했으나, `memory: local`이 `.claude/agent-memory-local/`에 저장된다는 사실이 누락.

## 확인된 정확한 내용

- 프로젝트/글로벌 트리 구조 전반 정확
- CLAUDE.md 200줄 권장, MEMORY.md 200줄/25KB 제한 정확
- rules/ paths 조건부 로드, skills/ SKILL.md frontmatter 4개 필드 정확
- 배열 합산/스칼라 최구체 병합 설명 정확
- 코드 예시 전반 원본과 일치
