param(
  [Parameter(Mandatory=$true)]
  [string]$Uri,

  [Parameter(Mandatory=$true)]
  [string]$JsonBody,

  [ValidateSet('GET','POST','PUT','PATCH','DELETE')]
  [string]$Method = 'POST',

  [string]$UserAgent = 'pwsh-client/1.0',
  [string]$TraceParent = '00-00000000000000000000000000000000-0000000000000000-01'
)

$csharp = @"
using System;
using System.Net;
using System.Net.Http;
using System.Text;
using System.Text.RegularExpressions;

public static class ApiCaller
{
    public static int Run(string uri, string jsonBody, string method, string userAgent, string traceParent)
    {
        Console.OutputEncoding = Encoding.UTF8;
        ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls12;

        if (string.IsNullOrEmpty(method))
        {
            method = "POST";
        }

        int statusCode = 0;
        string rawBody = null;

        using (var client = new HttpClient())
        using (var request = new HttpRequestMessage(new HttpMethod(method), uri))
        {
            if (!string.IsNullOrEmpty(userAgent))
            {
                request.Headers.TryAddWithoutValidation("User-Agent", userAgent);
            }

            if (!string.IsNullOrEmpty(traceParent))
            {
                request.Headers.TryAddWithoutValidation("traceparent", traceParent);
            }

            string bodyValue = jsonBody ?? string.Empty;
            request.Content = new StringContent(bodyValue, Encoding.UTF8, "application/json");

            HttpResponseMessage response = null;
            try
            {
                response = client.SendAsync(request).GetAwaiter().GetResult();
                statusCode = (int)response.StatusCode;
                rawBody = response.Content.ReadAsStringAsync().GetAwaiter().GetResult();
            }
            catch (Exception ex)
            {
                rawBody = ex.Message;
            }
            finally
            {
                if (response != null)
                {
                    response.Dispose();
                }
            }
        }

        string decoded = DecodeUnicodeEscapes(rawBody);
        Console.WriteLine("StatusCode: {0}", statusCode);
        if (decoded != null)
        {
            Console.WriteLine(decoded);
        }

        return statusCode;
    }

    private static string DecodeUnicodeEscapes(string text)
    {
        if (string.IsNullOrEmpty(text))
        {
            return text;
        }

        string decoded = Regex.Replace(text, @"\\\\u([0-9a-fA-F]{4})", m =>
        {
            int value = Convert.ToInt32(m.Groups[1].Value, 16);
            return ((char)value).ToString();
        });

        decoded = Regex.Replace(decoded, @"\\u([0-9a-fA-F]{4})", m =>
        {
            int value = Convert.ToInt32(m.Groups[1].Value, 16);
            return ((char)value).ToString();
        });

        return decoded;
    }
}
"@

if (-not ("ApiCaller" -as [type])) {
  Add-Type -TypeDefinition $csharp -Language CSharp -ReferencedAssemblies 'System.Net.Http'
}

[ApiCaller]::Run($Uri, $JsonBody, $Method, $UserAgent, $TraceParent) | Out-Null
