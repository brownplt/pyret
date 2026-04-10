<!doctype html>
<html lang="en">
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-sRIl4kxILFvY47J16cr9ZwB07vP4J8+LH7qKQnuqkuIAvNWLzeN8tE5YBujZqJLB" crossorigin="anonymous">
  <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Rounded:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200"/>
  <script src="https://ajax.googleapis.com/ajax/libs/jquery/2.1.1/jquery.min.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/js/bootstrap.bundle.min.js" integrity="sha384-FKyoEForCGlyvwx9Hj09JcYn3nv7wiPVlz7YYwJrWVcXK/BmnVDxM+D2scQbITxI" crossorigin="anonymous"></script>
  <script src="◊(prefix-dir (point-to-project-root here) (symbol->string './pollenboots/codemirror.js))"></script>
  <script src="◊(prefix-dir (point-to-project-root here) (symbol->string './pollenboots/runmode.js))"></script>
  <script src="◊(prefix-dir (point-to-project-root here) (symbol->string './pollenboots/pyret.js))"></script>
  <script src="◊(prefix-dir (point-to-project-root here) (symbol->string './pollenboots/hilite.js))"></script>
  <script src="◊(prefix-dir (point-to-project-root here) (symbol->string './pollenboots/search.js))"></script>
  <script src="◊(prefix-dir (point-to-project-root here) (symbol->string './pollenboots/pyret_2.js))"></script>
  <script src="◊(prefix-dir (point-to-project-root here) (symbol->string './pollenboots/default-rpcs.js))"></script>
  <script type="module" src="◊(prefix-dir (point-to-project-root here) (symbol->string './pollenboots/embed-api.js))"></script>
  <script src="◊(prefix-dir (point-to-project-root here) (symbol->string './pollenboots/scribble-common.js))"></script>
  <link rel="stylesheet" type="text/css" href="◊(prefix-dir (point-to-project-root here) (symbol->string './pollenboots/codemirror.css))" title="default"/>
  <link rel="stylesheet" type="text/css" href="◊(prefix-dir (point-to-project-root here) (symbol->string './pollenboots/pyret.css))" title="default"/>
  <link rel="stylesheet" type="text/css" href="◊(prefix-dir (point-to-project-root here) (symbol->string './styles.css))" title="default"/>
  <style>
◊(let* ([here-str (if (symbol? here) (symbol->string here) here)]
        [here-html (regexp-replace "\\.poly\\.pm$" (from-project-root here-str) ".html")])
   (section-number-css here-html))
  </style>
  <head>
    <title>◊(doc-title doc)</title>
  </head>
  <body>
    <div class="topbar">
      <a href="◊(prefix-dir (point-to-project-root here) (symbol->string './index.html))"><img class="topbar-logo" src="◊(prefix-dir (point-to-project-root here) (symbol->string './assets/Pyret.png))" alt="Pyret logo"/></a>
      <form class="searchform" id="searchformid">
        <span class="material-symbols-rounded search-icon">search</span>
        <input class="searchbox" id="searchbox" type="text" tabindex="1" placeholder="Search..." title="Enter a search string to search the manuals" onkeypress="return DoSearchKey(event, this, &quot;9.1&quot;, &quot;&quot;);"/>
      </form>
      <nav class="topbar-links">
        <a class="topbar-link" href="#">Testing and Assertions</a>
        <a class="topbar-link" href="#">Release Notes</a>
        <a class="topbar-link" href="#">Discussion List</a>
      </nav>
    </div>
    ◊(define top-dir (point-to-project-root here))
    <div class="page-body">
      <div class="sidebar">
        ◊(->html (make-sidebar here top-dir))
      </div>
      <div class="container">
      ◊(->html doc)
      ◊(define prev-page (prefix-dir top-dir (previous here)))
      ◊(define next-page (prefix-dir top-dir (next here)))
      <hr/>
      <!-- The current page is ◊|here|. -->
      ◊when/splice[prev-page]{
      <a class="floatleft" href="◊prev-page">⏴⏴⏴</a>
      }
      ◊when/splice[next-page]{
      <a class="floatright" href="◊next-page">⏵⏵⏵</a>
      }
      </div>
    </div>
  <script>
    const closeItem = (li) => {
      li.classList.remove('open');
      const chevron = li.querySelector('.sidebar-item-row .sidebar-chevron');
      if (chevron) chevron.setAttribute('aria-expanded', 'false');
    };

    // Chevron toggle — accordion within .sidebar-accordion lists
    document.querySelectorAll('.sidebar-chevron').forEach(btn => {
      btn.addEventListener('click', e => {
        e.preventDefault();
        e.stopPropagation();
        const li = btn.closest('.sidebar-item.has-children');
        const wasOpen = li.classList.contains('open');
        const parentUl = li.parentElement;

        // Accordion: only close siblings when opening a new item
        if (parentUl.classList.contains('sidebar-accordion') && !wasOpen) {
          [...parentUl.children].forEach(sibling => {
            if (sibling !== li && sibling.classList.contains('has-children')) {
              closeItem(sibling);
            }
          });
        }

        // Toggle the clicked item
        const nowOpen = !wasOpen;
        li.classList.toggle('open', nowOpen);
        btn.setAttribute('aria-expanded', nowOpen ? 'true' : 'false');

        // Mutual exclusion: when one opens, close the other.
        // Closing either side does NOT auto-open the other.
        if (nowOpen) {
          if (li.classList.contains('sidebar-pyret-concepts')) {
            const cs = document.querySelector('.sidebar-current-section');
            if (cs && cs.classList.contains('has-children')) closeItem(cs);
          } else if (li.classList.contains('sidebar-current-section')) {
            const pc = document.querySelector('.sidebar-pyret-concepts');
            if (pc) closeItem(pc);
          }
        }
      });
    });

    // Click flash: use mousedown so the flash is visible before navigation
    document.querySelectorAll('.sidebar-link').forEach(link => {
      link.addEventListener('mousedown', () => {
        link.classList.add('clicking');
        setTimeout(() => link.classList.remove('clicking'), 300);
      });
    });
  </script>
  </body>
</html>
