#!/usr/bin/env python3
"""PreToolUse gate: block posting a GitHub or Linear comment until claim-checker has run.

Allows the post only if a claim-checker subagent was launched after the user's latest prompt.
It proves the check ran this turn, not that it saw this exact text.
"""
import json
import re
import sys

GH_MUTATIONS = (
    "addPullRequestReview", "addPullRequestReviewThread", "addPullRequestReviewThreadReply",
    "addPullRequestReviewComment", "updatePullRequestReviewComment", "updatePullRequestReview",
    "submitPullRequestReview", "addComment", "updateIssueComment",
)
GH_CLI_POST = re.compile(r"\bgh\s+(pr|issue)\s+(comment|review)\b")
GH_API = re.compile(r"\bgh\s+api\b")
GH_REST_COMMENT = re.compile(r"/(comments|reviews)\b")
GH_REST_WRITE = re.compile(r"(-X|--method)\s*(POST|PATCH|PUT)|\s(-f|-F|--field|--raw-field|--input)\s")
LINEAR_TOOL = re.compile(r"^mcp__.*__(save_comment|save_diff_comment)$")

REASON = (
    "Comment not posted: claim-checker has not run this turn. "
    "Launch the claim-checker agent on the exact draft text, with the PR head SHA. "
    "Fix or cut every Wrong row, label Taste rows as taste, and resolve or soften Not checked rows. "
    "Then retry this post."
)


def is_post(tool_name, tool_input):
    if LINEAR_TOOL.match(tool_name):
        return True
    if tool_name != "Bash":
        return False
    cmd = tool_input.get("command", "")
    if GH_CLI_POST.search(cmd):
        return True
    if not GH_API.search(cmd):
        return False
    if any(re.search(rf"\b{m}\b", cmd) for m in GH_MUTATIONS):
        return True
    return bool(GH_REST_COMMENT.search(cmd) and GH_REST_WRITE.search(cmd))


def claim_checker_ran_this_turn(transcript_path):
    ran = False
    with open(transcript_path) as f:
        for line in f:
            try:
                entry = json.loads(line)
            except json.JSONDecodeError:
                continue
            if entry.get("type") == "user" and (entry.get("origin") or {}).get("kind") == "human":
                ran = False
                continue
            if entry.get("type") != "assistant":
                continue
            for block in entry.get("message", {}).get("content") or []:
                if (
                    isinstance(block, dict)
                    and block.get("type") == "tool_use"
                    and block.get("name") in ("Agent", "Task")
                    and (block.get("input") or {}).get("subagent_type") == "claim-checker"
                ):
                    ran = True
    return ran


def main():
    payload = json.load(sys.stdin)
    if not is_post(payload.get("tool_name", ""), payload.get("tool_input") or {}):
        return
    transcript_path = payload.get("transcript_path")
    if transcript_path and claim_checker_ran_this_turn(transcript_path):
        return
    print(json.dumps({
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "deny",
            "permissionDecisionReason": REASON,
        }
    }))


if __name__ == "__main__":
    main()
