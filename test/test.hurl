# Check main elements
GET http://localhost:1314
HTTP/1.1 200
[Asserts]
xpath "string(/html/body/div/main/div/article/h1)" == "Knowledge is Power"
xpath "string(/html/body/div/footer/nav/div[1]/section/span[1])" contains "Michael Peter - since 2017©"

# Check error handling
GET http://localhost:1314/foobar
HTTP/1.1 404

# Check imprint is available
GET http://localhost:1314/imprint/
HTTP/1.1 200
[Asserts]
xpath "string(/html/body/div/main/div/article/p[3])" contains "Verantwortlich für den Inhalt"

# Check privacy is available
GET http://localhost:1314/privacy/
HTTP/1.1 200
[Asserts]
xpath "string(//*[@id=\"dsg-general-controller\"])" contains "Verantwortlicher"

# Check RSS elements
GET http://localhost:1314/blog/index.xml
HTTP/1.1 200
[Asserts]
xpath "string(//rss/channel/title)"       == "Blog on Rootknecht.net"
xpath "string(//rss/channel/description)" == "Recent content in Blog on Rootknecht.net"

# Checking article count
GET http://localhost:1314/blog/
HTTP/1.1 200
[Asserts]
xpath "count(/html/body/div/main/div/article)" == 10

# Checking pagination count
GET http://localhost:1314/blog/
HTTP/1.1 200
[Asserts]
xpath "string(/html/body/div/main/div/nav/div[2])" == "1/3"

# Check section
GET http://localhost:1314/knowledge/programming/
HTTP/1.1 200
[Asserts]
xpath "string(/html/body/div/main/div/article/h1)" ==  "Programming"

# Check PGP public key
GET http://localhost:1314/Michael_Peter.asc
HTTP/1.1 200
[Asserts]
body contains "-----BEGIN PGP PUBLIC KEY BLOCK-----"
