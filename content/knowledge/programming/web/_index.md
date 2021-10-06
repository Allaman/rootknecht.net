---
title: Web
---

{{< toc >}}

## Start a simple web server for testing/developing

PHP

```bash
php -S localhost:8000
```

Python

```bash
python2 -m SimpleHTTPServer 8000
python3 -m http.server
```

JavaScript

```bash
npm install http-server –g
http-server
```

Buysbox

```sh
busybox httpd -p 127.0.0.1:8080 -h /var/www/
```

## CSS applying only on specified div

```css
.footer a.link {
  color: black;
}
```

## Modal overlay popup (button)

```html
<style>
  body {
    font-family: Arial, Helvetica, sans-serif;
  }

  /* The Modal (background) */
  .modal {
    display: none; /* Hidden by default */
    position: fixed; /* Stay in place */
    z-index: 1; /* Sit on top */
    padding-top: 100px; /* Location of the box */
    left: 0;
    top: 0;
    width: 100%; /* Full width */
    height: 100%; /* Full height */
    overflow: auto; /* Enable scroll if needed */
    background-color: rgb(0, 0, 0); /* Fallback color */
    background-color: rgba(0, 0, 0, 0.4); /* Black w/ opacity */
  }

  .btnFooter {
    background-color: transparent;
    -moz-border-radius: 28px;
    -webkit-border-radius: 28px;
    border-radius: 28px;
    border: 1px solid #eb3a12;
    display: inline-block;
    cursor: pointer;
    color: #eb3a12;
    font-family: Arial;
    font-size: 17px;
    padding: 16px 31px;
    text-decoration: none;
  }
  .btnFooter:hover {
    background-color: transparent;
  }
  .btnFooter:active {
    position: relative;
    top: 1px;
  }

  /* Modal Content */
  .modal-content {
    background-color: #fefefe;
    margin: auto;
    padding: 20px;
    border: 1px solid #888;
    width: 80%;
  }

  /* The Close Button */
  .close {
    color: #aaaaaa;
    float: right;
    font-size: 28px;
    font-weight: bold;
  }

  .close:hover,
  .close:focus {
    color: #000;
    text-decoration: none;
    cursor: pointer;
  }
</style>
<!-- Trigger/Open The Modal -->
<button id="btnPrivacy" class="btnFooter">Open Modal</button>

<!-- The Modal -->
<div id="myModal" class="modal">
  <!-- Modal content -->
  <div class="modal-content">
    <span class="close">&times;</span>
    <p>Some text in the Modal..</p>
  </div>
</div>

<script>
  // Get the modal
  var modal = document.getElementById("myModal");

  // Get the button that opens the modal
  var btn = document.getElementById("btnPrivacy");

  // Get the <span> element that closes the modal
  var span = document.getElementsByClassName("close")[0];

  // When the user clicks the button, open the modal
  btn.onclick = function () {
    modal.style.display = "block";
  };

  // When the user clicks on <span> (x), close the modal
  span.onclick = function () {
    modal.style.display = "none";
  };

  // When the user clicks anywhere outside of the modal, close it
  window.onclick = function (event) {
    if (event.target == modal) {
      modal.style.display = "none";
    }
  };
</script>
```

[source](https://www.w3schools.com/howto/howto_css_modals.asp)

## Modal overlay popup (link)

```html
<!-- Trigger the modal with a button -->
<a href="#Modal">Open Modal</a>
<!-- Modal -->
<div id="Modal" class="modal fade" role="dialog">
  <div class="modal-dialog">
    <!-- Modal content-->
    <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal">
          &times;
        </button>
        <h4 class="modal-title">Modal Header</h4>
      </div>
      <div class="modal-body">
        <p>Some text in the modal.</p>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-default" data-dismiss="modal">
          Close
        </button>
      </div>
    </div>
  </div>
</div>
<script type="text/javascript">
  $('a[href$="#Modal"]').on("click", function () {
    $("#Modal").modal("show");
  });
</script>
```

[source](https://stackoverflow.com/questions/50210529/open-bootstrap-4-modal-via-javascript-by-clicking-a-link)
