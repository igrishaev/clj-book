(ns makeindex.core
  (:require
   [clojure.string :as str])
  (:gen-class))

(def path-in "/Users/ivan/work/clj-book/main.idx")
(def path-out "/Users/ivan/work/clj-book/main.ind")

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


(defn line->terms-page [line]
  (when-let [result (re-matches re-line line)]
    (let [[_ str-terms str-page] result
          terms (str/split str-terms #"!")
          [[T]] terms
          page (Integer/parseInt str-page)]
      [(into [T] terms) page])))


(defn lines->tree [parsed]
  (reduce
   (fn [index [terms page]]
     (update-in index (conj terms :__pages) conj page))
   {}
   parsed))


(defn path->lines [path]
  (-> path
      slurp
      (clojure.string/split #"\n")))


(defn str-repeat [n str]
  (str/join (repeat n str)))


(defn print-tree [tree & [{level :level
                           :as opt
                           :or {level 0}}]]

  (doseq [[term childs] (sort-by first tree)]

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
        (print (str/join ", " (sort (set pages))))
        (when w4 (print w4)))

      (println)

      (when-let [tree* (-> childs (dissoc :__pages) not-empty)]
        (print-tree tree* (update opt :level (fnil inc 0))))

      (when after
        (print indent)
        (println after)))))


(defn save-file [tree]
  (let [out (with-out-str
              (println "\\begin{theindex}")
              (print-tree tree)
              (println "\\end{theindex}"))]
    (spit path-out out)))


(defn aaaaa []
  (->> path-in
       path->lines
       (map line->terms-page)
       lines->tree
       save-file))


#_
(defn -main
  "I don't do a whole lot ... yet."
  [& args]
  (println "Hello, World!"))
