;   Copyright (c) Rich Hickey. All rights reserved.
;   The use and distribution terms for this software are covered by the
;   Eclipse Public License 1.0 (http://opensource.org/licenses/eclipse-1.0.php)
;   which can be found in the file epl-v10.html at the root of this distribution.
;   By using this software in any fashion, you are agreeing to be bound by
;   the terms of this license.
;   You must not remove this notice, or any other, from this software.

(ns clojure.test-clojure.datafy
  (:use clojure.test)
  (:require [clojure.datafy :as datafy]))

;; datafy must record the fully-qualified class name

(deftest class-metadata-is-fully-qualified
  ;; datafy attaches ::class when x is transformed into a different IObj; Namespace does this
  (let [c (::datafy/class (meta (datafy/datafy (find-ns 'clojure.core))))]
    (is (= 'clojure.lang.Namespace c))
    ;; the recorded name must resolve back to the class
    (is (= clojure.lang.Namespace (clojure.lang.RT/classForName (name c))))))

(deftest type-name-is-fully-qualified
  (let [nm (:name (datafy/datafy System.Text.StringBuilder))]
    (is (= 'System.Text.StringBuilder nm))
    (is (= System.Text.StringBuilder (clojure.lang.RT/classForName (name nm))))))

