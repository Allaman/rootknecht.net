# Check main elements
GET http://localhost:1313
HTTP/1.1 200
[Asserts]
xpath "string(/html/body/div/main/div/article/h1)" == "Knowledge is Power"
xpath "string(/html/body/div/footer/div/div[1]/span[1])" contains "Michael Peter 2022©"

# Check error handling
GET http://localhost:1313/foobar
HTTP/1.1 404

# Check imprint is available
GET http://localhost:1313/imprint/
HTTP/1.1 200
[Asserts]
xpath "string(/html/body/div/main/div/article/p[3])" contains "Verantwortlich für den Inhalt"

# Check privacy is available
GET http://localhost:1313/privacy/
HTTP/1.1 200
[Asserts]
xpath "string(//*[@id=\"dsg-general-controller\"])" contains "Verantwortlicher"

# Check RSS elements
GET http://localhost:1313/blog/index.xml
HTTP/1.1 200
[Asserts]
xpath "string(//rss/channel/title)"       == "Blog on Rootknecht.net"
xpath "string(//rss/channel/description)" == "Recent content in Blog on Rootknecht.net"

# Checking article count
GET http://localhost:1313/blog/
HTTP/1.1 200
[Asserts]
xpath "count(/html/body/div/main/div/article)" >= 22

# Check section
GET http://localhost:1313/knowledge/programming/
HTTP/1.1 200
[Asserts]
xpath "string(/html/body/div/main/div/article/h1)" ==  "Programming"

# Check PGP public key
GET http://localhost:1313/Michael_Peter.pgp
HTTP/1.1 200
[Asserts]
body contains "-----BEGIN PGP PUBLIC KEY BLOCK-----"
