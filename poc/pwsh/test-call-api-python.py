import argparse
import os
import subprocess
import sys


def main():
    parser = argparse.ArgumentParser(description="Run success and error tests for call-api-python.py")
    parser.add_argument("--success-uri", default="https://httpbin.org/post")
    parser.add_argument("--error-uri", default="https://httpbin.org/status/418")
    parser.add_argument("--user-agent", default="py-test/1.0")
    parser.add_argument("--traceparent", default="00-11111111111111111111111111111111-2222222222222222-01")
    args = parser.parse_args()

    script_dir = os.path.dirname(os.path.abspath(__file__))
    target_script = os.path.join(script_dir, "call-api-python.py")

    if not os.path.exists(target_script):
        print("call-api-python.py not found at {0}".format(target_script), file=sys.stderr)
        return 1

    payload = '{"text":"\\u65e5\\u672c"}'
    python_exe = sys.executable or "python"

    print("--- Success case (200) ---")
    subprocess.run(
        [
            python_exe,
            target_script,
            "--uri",
            args.success_uri,
            "--json-body",
            payload,
            "--user-agent",
            args.user_agent,
            "--traceparent",
            args.traceparent,
        ],
        check=False,
    )

    print("")
    print("--- Error case (non-200) ---")
    subprocess.run(
        [
            python_exe,
            target_script,
            "--uri",
            args.error_uri,
            "--json-body",
            payload,
            "--user-agent",
            args.user_agent,
            "--traceparent",
            args.traceparent,
        ],
        check=False,
    )

    return 0


if __name__ == "__main__":
    sys.exit(main())
