Below is a practical “dev CA / self-signed” setup for **Fiber v3** + how to make clients trust your cert on **Linux**, **Windows**, and **Java 8**.

## 1) Fiber v3: serve HTTPS (TLS)

### A) Easiest: point Fiber to cert + key files

```go
package main

import (
	"log"

	"github.com/gofiber/fiber/v3"
)

func main() {
	app := fiber.New()

	app.Get("/", func(c fiber.Ctx) error {
		return c.SendString("hello https (fiber v3)")
	})

	log.Fatal(app.Listen(":8443", fiber.ListenConfig{
		CertFile:    "./server.crt",
		CertKeyFile: "./server.key",
	}))
}
```

Fiber v3 supports TLS via `fiber.ListenConfig{CertFile, CertKeyFile}`. ([Fiber Documentation][1])

### B) Recommended when you want full control: `TLSConfig`

```go
package main

import (
	"crypto/tls"
	"log"

	"github.com/gofiber/fiber/v3"
)

func main() {
	app := fiber.New()

	cer, err := tls.LoadX509KeyPair("./server.crt", "./server.key")
	if err != nil {
		log.Fatal(err)
	}

	log.Fatal(app.Listen(":8443", fiber.ListenConfig{
		TLSConfig: &tls.Config{
			MinVersion:   tls.VersionTLS12,
			Certificates: []tls.Certificate{cer},
		},
	}))
}
```

Fiber v3 docs explicitly recommend `TLSConfig` (and say it overrides the other TLS fields). ([Fiber Documentation][1])

---

## 2) Trusting the certificate (so browsers / clients don’t warn)

### Important: what cert should you install?

* If you created a **Root CA** (`dev-rootCA.crt`) and used it to sign `server.crt`: **install the Root CA cert** on client machines (best practice).
* If you only created a **single self-signed server cert** (`cert.pem`): you *can* import that cert into the trust store, but it’s basically “trust this exact leaf cert as a root” (OK for quick dev, less clean).

Below, I’ll say “Root CA cert” — substitute your self-signed server cert if that’s all you have.

---

## 3) Trust on Linux machine

### Debian/Ubuntu (system-wide trust)

Ubuntu’s official approach is:

1. copy the PEM `.crt` into `/usr/local/share/ca-certificates/`
2. run `update-ca-certificates` ([Ubuntu Documentation][2])

```bash
sudo apt-get install -y ca-certificates
sudo cp dev-rootCA.crt /usr/local/share/ca-certificates/dev-rootCA.crt
sudo update-ca-certificates
```

Verify quickly:

```bash
openssl verify -CApath /etc/ssl/certs dev-rootCA.crt
```

Notes:

* The file must end with `.crt` to be processed. ([Ubuntu Documentation][2])
* Some snap-packaged apps/browsers may not automatically use the system trust store. ([Ubuntu Documentation][2])

### RHEL/CentOS/Fedora family

A common workflow is:

* drop the CA cert in one of the CA-trust source directories
* run `update-ca-trust` ([Red Hat][3])

Typical (anchors) path:

```bash
sudo cp dev-rootCA.crt /etc/pki/ca-trust/source/anchors/dev-rootCA.crt
sudo update-ca-trust
```

(Exact directories can vary by distro; `update-ca-trust` is the key step.) ([Red Hat][3])

---

## 4) Trust on Windows machine

### GUI (recommended)

Import your **Root CA cert** into **Trusted Root Certification Authorities** (Local Computer) using MMC (Certificates snap-in). ([Microsoft Learn][4])

### Command line (Admin)

Windows provides `certutil -addstore` to add a cert to a store: ([Microsoft Learn][5])
The trusted root store name is `root`. ([Microsoft Learn][4])

Run in **elevated** CMD/PowerShell:

```bat
certutil -addstore -f root dev-rootCA.crt
```

---

## 5) Trust in Java 8 (keystore)

Java trusts CAs from a keystore, commonly the global `cacerts` file. IBM’s Java 8 docs explain:

* `cacerts` is a system-wide keystore
* default password is `changeit`
* manage it with `keytool` ([IBM][6])

### Option A (best for dev apps): create a dedicated truststore (no admin needed)

```bash
keytool -importcert -alias dev-rootca \
  -file dev-rootCA.crt \
  -keystore dev-truststore.jks \
  -storepass changeit -noprompt
```

Then start your Java app with:

```bash
java \
  -Djavax.net.ssl.trustStore=dev-truststore.jks \
  -Djavax.net.ssl.trustStorePassword=changeit \
  -jar yourapp.jar
```

### Option B (system-wide): import into Java’s `cacerts`

Find your `cacerts` path (often one of these):

* `.../jre/lib/security/cacerts` (common in JDK8 layouts)
* `.../lib/security/cacerts`

Import:

```bash
sudo keytool -importcert -alias dev-rootca \
  -file dev-rootCA.crt \
  -keystore "$JAVA_HOME/jre/lib/security/cacerts" \
  -storepass changeit
```

List to verify:

```bash
keytool -list -v -keystore "$JAVA_HOME/jre/lib/security/cacerts" -storepass changeit
```

(These steps—password, import, list—match the Java 8 `cacerts` guidance.) ([IBM][6])

### If keytool complains about PEM

Some environments prefer DER. Convert PEM → DER:

```bash
openssl x509 -outform der -in dev-rootCA.crt -out dev-rootCA.der
```

…and import the `.der` instead. ([IBM][6])

---

## Quick troubleshooting checklist

* **Name mismatch**: Your server cert SAN must include the exact **hostname/IP** clients use (e.g., `DNS:myhost.local` or `IP:192.168.1.50`).
* **Untrusted issuer**: You imported the wrong cert. Usually you must import the **Root CA** that signed the server cert (not the leaf), especially for Java.

If you paste the filenames you ended up with (e.g. `dev-rootCA.crt`, `server.crt`, `server.key`) and how clients access the server (`https://localhost`, `https://192.168...`, `https://mybox.local`), I’ll tell you exactly which one to install where (and what SAN entries must exist).

[1]: https://docs.gofiber.io/next/api/fiber/ " Fiber | Fiber"
[2]: https://documentation.ubuntu.com/server/how-to/security/install-a-root-ca-certificate-in-the-trust-store/ "Install a root CA certificate in the trust store - Ubuntu Server documentation"
[3]: https://www.redhat.com/en/blog/configure-ca-trust-list "How to configure your CA trust list in Linux"
[4]: https://learn.microsoft.com/en-us/windows-hardware/drivers/install/trusted-root-certification-authorities-certificate-store "Trusted Root Certification Authorities Certificate Store - Windows drivers | Microsoft Learn"
[5]: https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/certutil "certutil | Microsoft Learn"
[6]: https://www.ibm.com/docs/en/sdk-java-technology/8?topic=certificate-cacerts-certificates-file "The cacerts Certificates File"
