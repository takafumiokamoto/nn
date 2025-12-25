import argparse
import re
import sys
import urllib.error
import urllib.request


def decode_unicode_escapes(text):
    if not text:
        return text

    def repl(match):
        return chr(int(match.group(1), 16))

    text = re.sub(r'\\\\u([0-9a-fA-F]{4})', repl, text)
    text = re.sub(r'\\u([0-9a-fA-F]{4})', repl, text)
    return text


def read_response(response):
    data = response.read()
    charset = response.headers.get_content_charset() or "utf-8"
    try:
        return data.decode(charset, errors="replace")
    except LookupError:
        return data.decode("utf-8", errors="replace")


def main():
    parser = argparse.ArgumentParser(description="Call an HTTP API with JSON body and custom headers.")
    parser.add_argument("--uri", required=True)
    parser.add_argument("--json-body", required=True)
    parser.add_argument("--method", default="POST", choices=["GET", "POST", "PUT", "PATCH", "DELETE"])
    parser.add_argument("--user-agent", default="pwsh-client/1.0")
    parser.add_argument("--traceparent", default="00-00000000000000000000000000000000-0000000000000000-01")
    args = parser.parse_args()

    body_bytes = args.json_body.encode("utf-8")

    request = urllib.request.Request(args.uri, data=body_bytes, method=args.method)
    request.add_header("Content-Type", "application/json; charset=utf-8")
    request.add_header("User-Agent", args.user_agent)
    request.add_header("traceparent", args.traceparent)

    status_code = 0
    raw_body = None

    try:
        with urllib.request.urlopen(request) as response:
            status_code = response.getcode()
            raw_body = read_response(response)
    except urllib.error.HTTPError as http_error:
        status_code = http_error.code
        raw_body = read_response(http_error)
    except Exception as exc:
        raw_body = str(exc)

    decoded = decode_unicode_escapes(raw_body)
    print("StatusCode: {0}".format(status_code))
    if decoded is not None:
        print(decoded)

    return 0


if __name__ == "__main__":
    sys.exit(main())
