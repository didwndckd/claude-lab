---
name: extend-claude-code.md 팩트체크 결과
description: claude-code-basic/extend-claude-code.md 문서의 공식 문서 대비 오류 및 의심 사항 검토 기록 (2026-03-21)
type: project
---

2026-03-21에 extend-claude-code.md를 공식 docs(code.claude.com/docs/ko/) 대비 팩트체크 수행.

주요 발견 오류:
1. CLAUDE.md 권장 줄 수: 문서는 "약 500줄 이하"라고 쓰지만 공식 문서는 "200줄 이하"(memory 페이지)를 기준으로 사용
2. Subagent 우선순위 표: 문서는 "관리 > CLI 플래그 > 프로젝트 > 사용자 > 플러그인"이라고 쓰지만, Skill 우선순위 표는 공식 문서와 일치
3. MCP 서버 우선순위 표: 문서는 "로컬 > 프로젝트 > 사용자"라고 쓰지만 공식 문서 MCP 페이지는 이름을 다르게 사용 ("local > project > user"이지만 실제 저장 위치 설명이 복잡)
4. 컨텍스트 비용 표: "도구 검색으로 최대 10%까지 제한"은 정확 — features-overview에서 확인됨
5. `disable-model-invocation: true`로 컨텍스트 비용 0 — 정확

**Why:** 공식 문서에서 메모리 권장 크기가 "200줄"로 명시되어 있으나 문서는 "500줄"로 잘못 기술
**How to apply:** 동 파일 재검토 시 CLAUDE.md 권장 크기 항목을 우선 확인할 것
