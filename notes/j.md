To “globally” trust an internal CA in Java 8, you typically import the CA certificate into the JRE’s default truststore: $JAVA_HOME/jre/lib/security/cacerts (or sometimes $JAVA_HOME/lib/security/cacerts, depending on the JDK distribution).

Even if your CA “does not have a chain”, the key point is: you should import the CA certificate (root and/or intermediate), not the server/leaf cert. Java trusts servers by building a chain to a trusted CA in the truststore.

⸻

1) Find the Java 8 global truststore (“cacerts”)

Common locations
	•	Oracle/OpenJDK Java 8 (classic layout):
	•	"$JAVA_HOME/jre/lib/security/cacerts"
	•	Some OpenJDK builds:
	•	"$JAVA_HOME/lib/security/cacerts"

Check:

echo "$JAVA_HOME"
ls -l "$JAVA_HOME/jre/lib/security/cacerts" "$JAVA_HOME/lib/security/cacerts" 2>/dev/null


⸻

2) Import the PEM CA cert into cacerts

If you have a PEM file like internal-ca.pem

Import with keytool:

sudo keytool -importcert -trustcacerts \
  -alias internal-ca \
  -file /path/to/internal-ca.pem \
  -keystore "$JAVA_HOME/jre/lib/security/cacerts"

Notes:
	•	Default cacerts password is usually: changeit
	•	Use sudo if the JDK is under a protected directory (common on Linux).

If your Java 8 uses the other path:

sudo keytool -importcert -trustcacerts \
  -alias internal-ca \
  -file /path/to/internal-ca.pem \
  -keystore "$JAVA_HOME/lib/security/cacerts"

You’ll be prompted to confirm the certificate details—type yes.

⸻

3) Verify it’s there

keytool -list -keystore "$JAVA_HOME/jre/lib/security/cacerts" -alias internal-ca

(or swap the path)

⸻

4) What if there’s “no chain”?

Case A: You truly only have a single CA cert (root-only PKI)

That’s fine. Import that CA cert (as above). Servers should present their leaf cert; clients build trust to the CA.

Case B: Your org has an intermediate CA, but your PEM file doesn’t include it

You must import each CA cert you have (root + intermediate). Java won’t “invent” missing intermediates.

Import each with a different alias:

sudo keytool -importcert -trustcacerts -alias internal-root-ca -file root.pem \
  -keystore "$JAVA_HOME/jre/lib/security/cacerts"

sudo keytool -importcert -trustcacerts -alias internal-intermediate-ca -file intermediate.pem \
  -keystore "$JAVA_HOME/jre/lib/security/cacerts"

Case C: You have a bundle PEM containing multiple certs

keytool -importcert sometimes only imports the first cert from a PEM bundle, depending on version/vendor.
Best practice: split the bundle into individual PEM files (root/intermediate) and import them separately.

⸻

5) Important operational notes
	•	This changes the truststore for that specific JRE/JDK install.
If you have multiple Java 8 installs, repeat per install.
	•	Upgrades can overwrite cacerts.
Many teams prefer creating a custom truststore and pointing apps to it via:
	•	-Djavax.net.ssl.trustStore=/path/to/mytruststore.jks
	•	-Djavax.net.ssl.trustStorePassword=...
	•	Don’t import server leaf certs unless you intentionally want to pin trust to that one server (it breaks when the cert rotates).

⸻

Quick troubleshooting

“keytool: command not found”

Use:

"$JAVA_HOME/bin/keytool" ...

“Keystore was tampered with, or password incorrect”

You entered the wrong cacerts password. Default is often changeit, but your environment may differ.

“PKIX path building failed”

Usually means:
	•	you imported the wrong cert (leaf instead of CA), or
	•	the server is missing intermediates, or
	•	you didn’t import the intermediate CA.

⸻

If you paste:
	1.	the output of java -version, and
	2.	whether your PEM is root CA, intermediate CA, or server cert,
I can tell you exactly which imports you need and which cacerts path is correct for your install.

import javax.net.ssl.HttpsURLConnection;
import javax.net.ssl.SSLContext;
import javax.net.ssl.SSLSocketFactory;
import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.URL;
import java.nio.charset.StandardCharsets;

public class MinimalHttpsPostJava8 {
    public static void main(String[] args) throws Exception {
        // Usage: java MinimalHttpsPostJava8 https://httpbin.org/post '{"hello":"world"}'
        String urlStr = (args.length > 0) ? args[0] : "https://httpbin.org/post";
        String jsonBody = (args.length > 1) ? args[1] : "{\"hello\":\"world\"}";

        // Force TLS 1.2 using a dedicated SSLContext and socket factory.
        SSLContext tls12 = SSLContext.getInstance("TLSv1.2");
        tls12.init(null, null, null);
        SSLSocketFactory tls12Factory = tls12.getSocketFactory();

        URL url = new URL(urlStr);
        HttpsURLConnection conn = (HttpsURLConnection) url.openConnection();
        conn.setSSLSocketFactory(tls12Factory);

        conn.setRequestMethod("POST");
        conn.setDoOutput(true);

        // Headers
        conn.setRequestProperty("User-Agent", "MinimalJava8Client/1.0");
        conn.setRequestProperty("Content-Type", "application/json; charset=utf-8");
        conn.setRequestProperty("Accept", "*/*");

        // Write request body
        byte[] out = jsonBody.getBytes(StandardCharsets.UTF_8);
        conn.setFixedLengthStreamingMode(out.length);
        conn.connect();
        try (OutputStream os = conn.getOutputStream()) {
            os.write(out);
        }

        // Read response
        int code = conn.getResponseCode();
        InputStream is = (code >= 200 && code < 400) ? conn.getInputStream() : conn.getErrorStream();

        StringBuilder sb = new StringBuilder();
        if (is != null) {
            try (BufferedReader br = new BufferedReader(new InputStreamReader(is, StandardCharsets.UTF_8))) {
                String line;
                while ((line = br.readLine()) != null) {
                    sb.append(line).append('\n');
                }
            }
        }

        // Print status + body to stdout
        System.out.println("HTTP " + code);
        System.out.print(sb.toString());

        conn.disconnect();
    }
}



Below is a minimal Fiber v3 HTTPS server that:
	•	Enforces TLS 1.2+ (MinVersion: tls.VersionTLS12)
	•	Uses a dedicated self-signed CA to verify client certificates (mTLS) via ClientCAs + ClientAuth
	•	Serves one POST endpoint and prints nothing fancy

Fiber v3 recommends using TLSConfig for full TLS control, including mTLS (ClientAuth, ClientCAs).  ￼

⸻

main.go

package main

import (
	"crypto/tls"
	"crypto/x509"
	"fmt"
	"log"
	"os"

	"github.com/gofiber/fiber/v3"
)

func main() {
	// Files you provide:
	// - ca.pem:        your self-signed CA certificate (PEM)
	// - server.pem:    server certificate (PEM) (typically signed by ca.pem)
	// - server-key.pem server private key (PEM)
	// - client certs:  issued by ca.pem (clients present these)
	const (
		caFile     = "./ca.pem"
		serverCert = "./server.pem"
		serverKey  = "./server-key.pem"
		addr       = ":8443"
	)

	// Load the dedicated CA (used to verify *client* certs)
	caPEM, err := os.ReadFile(caFile)
	if err != nil {
		log.Fatalf("read CA file: %v", err)
	}
	caPool := x509.NewCertPool()
	if ok := caPool.AppendCertsFromPEM(caPEM); !ok {
		log.Fatalf("failed to parse CA PEM: %s", caFile)
	}

	// Load server cert/key
	cert, err := tls.LoadX509KeyPair(serverCert, serverKey)
	if err != nil {
		log.Fatalf("load server keypair: %v", err)
	}

	// Build TLS config:
	// - TLS 1.2+ only
	// - Require and verify client certificates using our CA pool (mTLS)
	tlsConfig := &tls.Config{
		MinVersion:   tls.VersionTLS12,
		Certificates: []tls.Certificate{cert},

		ClientCAs:  caPool,
		ClientAuth: tls.RequireAndVerifyClientCert,
	}

	app := fiber.New()

	app.Post("/api", func(c fiber.Ctx) error {
		// Echo request body back, just as a minimal POST example.
		return c.SendString(fmt.Sprintf("ok: %s\n", c.Body()))
	})

	log.Printf("Listening on https://localhost%s (TLS>=1.2, mTLS required)\n", addr)
	log.Fatal(app.Listen(addr, fiber.ListenConfig{
		TLSConfig: tlsConfig,
	}))
}

go.mod (minimal)

module example.com/fiber-mtls

go 1.20

require github.com/gofiber/fiber/v3 v3.0.0


⸻

Quick test (curl)

If you require mTLS (as above), you must pass a client cert/key issued by ca.pem:

curl -vk https://localhost:8443/api \
  --cert ./client.pem --key ./client-key.pem \
  --cacert ./ca.pem \
  -d 'hello'

	•	--cacert ./ca.pem tells curl to trust your self-signed CA for the server certificate.
	•	--cert/--key sends the client certificate for mTLS.

⸻

Notes you’ll care about
	•	If you don’t want mandatory mTLS, change:
	•	ClientAuth: tls.VerifyClientCertIfGiven (optional client certs)
	•	or remove ClientAuth/ClientCAs entirely (plain TLS)
	•	If you’re using TLSConfig, Fiber v3 ignores CertFile, TLSMinVersion, etc. (so set everything in tls.Config).  ￼

If you tell me whether you want mandatory mTLS or optional mTLS, I can give you the exact ClientAuth setting and a matching curl command.

Here’s a minimal systemd unit that runs your Fiber app on port 443. This assumes your app reads the listen address from an env var (recommended), but I’ll also show the “hardcoded :443” case.

Option A (recommended): app listens from LISTEN_ADDR

Example snippet for Go (so the unit can set the port cleanly):

addr := os.Getenv("LISTEN_ADDR")
if addr == "" {
    addr = ":8443"
}
log.Fatal(app.Listen(addr, fiber.ListenConfig{TLSConfig: tlsConfig}))

/etc/systemd/system/fiber-app.service

[Unit]
Description=Fiber v3 HTTPS API (TLS>=1.2, mTLS)
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=fiber
Group=fiber
WorkingDirectory=/opt/fiber-app

# Where your compiled binary lives:
ExecStart=/opt/fiber-app/fiber-app

# Listen on 443 (requires privileges; see notes below for alternatives)
Environment=LISTEN_ADDR=:443

# If your app reads cert paths from env, set them here too (optional)
# Environment=CA_FILE=/opt/fiber-app/certs/ca.pem
# Environment=SERVER_CERT=/opt/fiber-app/certs/server.pem
# Environment=SERVER_KEY=/opt/fiber-app/certs/server-key.pem

Restart=on-failure
RestartSec=2

# Security hardening (safe defaults for most apps)
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=true
ReadWritePaths=/opt/fiber-app
AmbientCapabilities=CAP_NET_BIND_SERVICE
CapabilityBoundingSet=CAP_NET_BIND_SERVICE

# Logging
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target

Enable + start

sudo systemctl daemon-reload
sudo systemctl enable --now fiber-app.service
sudo systemctl status fiber-app.service


⸻

Option B: app is hardcoded to :443

If your Go code already does app.Listen(":443", ...), then omit the Environment=LISTEN_ADDR=:443 line and keep the rest the same.

⸻

Notes (important for port 443)

1) Binding to 443 without running as root

Port 443 is privileged (<1024). The unit above handles it safely by:
	•	Running as an unprivileged user (fiber)
	•	Granting only the capability needed to bind 443:
	•	AmbientCapabilities=CAP_NET_BIND_SERVICE
	•	CapabilityBoundingSet=CAP_NET_BIND_SERVICE

This is usually preferable to running the service as root.

2) Alternative: use a reverse proxy

A common production pattern is:
	•	Fiber listens on 127.0.0.1:8443
	•	nginx or HAProxy terminates TLS on 443 and proxies to Fiber
This avoids privileged ports and centralizes TLS.

3) SELinux (if applicable)

On SELinux-enabled systems, you may need additional policy changes even with capabilities.

⸻

If you want, paste your binary path and where your cert files live, and I’ll tailor the unit to your exact layout (including ReadOnlyPaths/ReadWritePaths and env vars).

