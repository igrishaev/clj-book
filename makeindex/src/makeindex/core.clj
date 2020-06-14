(ns makeindex.core
  (:require
   [clojure.string :as str])
  (:gen-class))


(def ebook?
  (-> (System/getenv "MODE")
      (= "ebook")))

(def re-line #"^\\indexentry\s\{(.+)\}\{(\d+)\}$")

(def wrap-pages ["\\hfill{\\slshape " "}"])

(def level-rules
  {0 {:wrap ["\\textbf{" "}"]
      :wrap-pages wrap-pages
      :func str/upper-case
      :after "\\indexspace"}
   1 {:wrap ["\\item "]
      :wrap-pages wrap-pages}
   2 {:wrap ["\\subitem ---~"]
      :wrap-pages wrap-pages}
   3 {:wrap ["\\subsubitem "]
      :wrap-pages wrap-pages}})


(defn unquote* [term]
  (-> term
      (str/replace #"\"!" "!")))


(defn line->terms-page [line]
  (when-let [result (re-matches re-line line)]
    (let [[_ str-terms str-page] result
          terms (str/split str-terms #"(?<!\")!")
          terms (mapv unquote* terms)
          T (-> terms first first str/upper-case)
          page (Integer/parseInt str-page)]
      [(into [T] terms) page])))


(defn lines->tree [lines]
  (reduce
   (fn [index [terms page]]
     (update-in index (conj terms :__pages) conj page))
   {}
   (map line->terms-page lines)))


(defn path->lines [path]
  (-> path
      slurp
      (clojure.string/split #"\n")))


(defn str-repeat [n str]
  (str/join (repeat n str)))


(defn term-sorter
  [[term _]]
  (str/upper-case term))


(def join (partial str/join ", "))


(defn print-tree [tree & [{level :level
                           :as opt
                           :or {level 0}}]]

  (doseq [[term childs] (sort-by term-sorter tree)]

    (let [{:keys [after wrap func wrap-pages]} (get level-rules level)
          [w1 w2] wrap
          [w3 w4] wrap-pages
          indent (str-repeat (* level 2) " ")]

      (print indent)
      (when w1 (print w1))
      (print (if func (func term) term))
      (when w2 (print w2))

      (when-let [pages (:__pages childs)]
        (print " ")
        (when w3 (print w3))

        (print (join
                (for [page (sort (set pages))]
                  (if ebook?
                    (format "\\hyperlink{page.%s}{%s}" page page)
                    page))))

        (when w4 (print w4)))

      (println)

      (when-let [tree* (-> childs (dissoc :__pages) not-empty)]
        (print-tree tree* (update opt :level (fnil inc 0))))

      (when after
        (print indent)
        (println after)))))


(defn save-file [tree file-out]
  (let [out (with-out-str
              (println "\\begin{theindex}")
              (print-tree tree)
              (println "\\end{theindex}"))]
    (spit file-out out)))


(defn process-files [file-in file-out]
  (-> file-in
      path->lines
      lines->tree
      (save-file file-out)))


(defn -main
  [& [file-in file-out]]
  (println ".idx:" file-in)
  (println ".ind:" file-out)
  (process-files file-in file-out)
  (println "done"))


#_
(-main "/Users/ivan/work/clj-book/main.idx"
       "/Users/ivan/work/clj-book/main.ind")
