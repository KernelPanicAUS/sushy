(import 
    [bottle    [abort get :as handle-get request redirect static-file view :as render-view]]
    [config    [*debug-mode* *home-page* *page-media-base* *page-route-base* *static-path* *store-path*]]
    [logging   [getLogger]]
    [models    [search get-links]]
    [os        [environ]]
    [render    [render-page]]
    [store     [get-page]]
    [transform [apply-transforms inner-html]])


(setv log (getLogger))


; TODO: etags and HTTP header handling for caching

(with-decorator 
    (handle-get "/")
    (handle-get *page-route-base*)
    (defn home-page []
        (redirect *home-page*)))


; environment dump
(with-decorator
    (handle-get "/env")
    (render-view "debug")
    (defn debug-dump []
        (if *debug-mode*
            {"headers" {"title" "Environment dump"}
             "environ"  (dict environ)}
            (abort (int 404) "Page Not Found"))))


; search
(with-decorator
    (handle-get "/search")
    (render-view "search")
    (defn handle-search []
        (if (in "q" (.keys (. request query)))
            {"results" (search (. request query q))
             "query"   (. request query q)
             "headers" {}}
            {"headers" {}})))

            
; static files
(with-decorator 
    (handle-get "/static/<filename:path>")
    (defn static-files [filename]
        (apply static-file [filename] {"root" *static-path*})))

        
; page media
(with-decorator 
    (handle-get (+ *page-media-base* "/<filename:path>"))
    (defn page-media [filename]
        (apply static-file [filename] {"root" *store-path*})))


; page content
(with-decorator 
    (handle-get (+ *page-route-base* "/<pagename:path>"))
    (render-view "wiki")
    (defn wiki-page [pagename] 
        ; TODO: fuzzy URL matching, error handling
        (let [[page (get-page pagename)]]
            {"headers"  (:headers page)
             "pagename" pagename
             "base_url" *page-route-base*
             "seealso"  (list (get-links pagename))
             "body"     (inner-html (apply-transforms (render-page page) pagename))})))
