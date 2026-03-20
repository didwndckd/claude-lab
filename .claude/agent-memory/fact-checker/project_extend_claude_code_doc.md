---
name: extend-claude-code.md 팩트체크 결과 (2026-03-21)
description: claude-code-basic/extend-claude-code.md 대 공식 문서 검증 결과 요약
type: project
---

검토한 문서: `/Users/yjc/Workspace/claude-lab-yjc/claude-code-basic/extend-claude-code.md`
검토일: 2026-03-21

## 주요 오류 발견

1. **CLAUDE.md 권장 크기 불일치**: 문서는 "약 500줄 이하"라고 기술하나, 공식 Memory 문서는 "200줄 이하"로 명시. Skills의 SKILL.md에 대해서는 500줄 권고가 맞음.

2. **MCP Tool Search 컨텍스트 비율 표현**: 문서는 "최대 10%까지 제한"이라고 표현하나, 공식 문서는 "10%를 초과할 때 자동으로 활성화"가 정확한 표현.

3. **Skill 우선순위 순서 오류**: 문서는 "관리 > 사용자 > 프로젝트" 순이라고 기술하나, 공식 Skills 문서는 "enterprise > personal > project" 순서로 동일하나, "CLI 플래그" 단계가 Skills에는 없음 (Subagent에만 있음).

4. **Subagent 우선순위 순서 확인 필요**: 문서는 "관리 > CLI 플래그 > 프로젝트 > 사용자 > 플러그인" 순이나, 공식 Subagents 문서의 실제 표에서는 "CLI 플래그 > 프로젝트 > 사용자 > 플러그인" 순서 (관리 최고, CLI 플래그 2위).

5. **CLAUDE.md vs Skill 비교 표 누락 항목**: 공식 문서는 "@path 가져오기", "워크플로우 트리거 가능" 등 추가 행이 있으나 문서 비교표에는 없음. 큰 오류는 아니나 누락 정보.

## 확인된 정확한 내용
- Skill vs Subagent 비교표 내용 정확
- Subagent vs Agent Team 비교표 내용 대체로 정확
- MCP vs Skill 비교표 정확
- Agent teams 실험적, 기본 비활성화 명시 정확
- Hooks 병합 특성 정확
- 기능 조합 패턴 표 정확

**Why:** 공식 문서와의 불일치를 향후 검토 시 빠르게 참조하기 위해 기록
**How to apply:** 이 문서의 후속 팩트체크나 수정 요청 시 참조
