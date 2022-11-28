GET http://localhost:1313

HTTP/1.1 200
[Asserts]
xpath "string(/html/body/div/main/div/article/h1)" == "Knowledge is Power"
# xpath "string(/html/body/div/footer/div/div[1]/span[1])" == "Michael Peter 2022©"

GET http://localhost:1313/foobar

HTTP/1.1 404

GET http://localhost:1313/knowledge/programming/

HTTP/1.1 200
[Asserts]
xpath "string(/html/body/div/main/div/article/h1)" ==  "Programming"
