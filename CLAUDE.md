# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 프로젝트 개요

Claude Code의 핵심 개념과 확장 기능을 정리한 한국어 지식 베이스 레포지토리. 코드 프로젝트가 아닌 문서 프로젝트이므로 빌드, 린트, 테스트 과정이 없다.

## 문서 작성 규칙

- **존댓말을 사용하지 않는다.** 해라체(~한다/~이다)로 작성한다.
- 불필요한 서론이나 배경 설명 없이 바로 본론으로 들어간다.
- 각 항목은 간결하게, 한눈에 파악할 수 있도록 작성한다.

## 구조

- `claude-code-basic/` — Claude Code 핵심 개념 문서 (작동 방식, 확장하기)
- `building-with-claude-code/` — Claude Code 활용 문서 (Skills, Subagent, Agent Teams)
- `.claude/agents/` — 커스텀 에이전트 정의 (fact-checker)
- `.claude/skills/` — 커스텀 스킬 정의 (summarize)

## 커스텀 도구

- **fact-checker 에이전트**: 문서의 사실 관계 검증용. Sonnet 모델 사용, 한국어로 결과 보고.
- **summarize 스킬** (`/summarize`): URL을 받아 요약 마크다운 문서를 생성하고 README.md에 링크 추가.

## 환경 설정

- Agent Teams 실험 기능 활성화됨 (`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`)
- 새 문서 추가 시 반드시 `README.md`에 링크를 갱신한다.
