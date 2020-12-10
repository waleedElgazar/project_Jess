;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; "CS Department"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Import some commonly-used classes
(import javax.swing.*)
(import java.awt.*)
(import java.awt.event.*)

;; Don't clear defglobals on (reset)
(set-reset-globals FALSE)

(defglobal ?*crlf* = "
")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Question and answer templates

(deftemplate question
  (slot text)
  (slot type)
  (multislot valid)
  (slot ident))

(deftemplate answer
  (slot ident)
  (slot text))

(do-backward-chaining answer)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Module app-rules

(defmodule app-rules)

(defrule app-rules::supply-answers
  (declare (auto-focus TRUE))
  (MAIN::need-answer (ident ?id))
  (not (MAIN::answer (ident ?id)))
  (not (MAIN::ask ?))
  =>
  (assert (MAIN::ask ?id))
  (return))

(defrule MAIN::gamal
  (declare (auto-focus TRUE))
  (answer (ident register) (text yes))
  (answer (ident age) (text yes))
  (answer (ident difference) (text yes))
  =>
  (recommend-action "u should lose 80 kg and follow captain gamal")
  (halt))

(defrule MAIN::waleed
  (declare (auto-focus TRUE))
  (answer (ident register) (text yes))
  (answer (ident age) (text yes))
  (answer (ident difference) (text no))
  =>
  (recommend-action "u should gain weight and follow captain waleed")
  (halt))

  (defrule MAIN::magdi
    (declare (auto-focus TRUE))
    (answer (ident register) (text yes))
    (answer (ident age) (text no))
    =>
    (recommend-action "u should follow captain magdi")
    (halt))

  (defrule MAIN::shahin
    (declare (auto-focus TRUE))
    (answer (ident register) (text no))
    =>
    (recommend-action "u should download the app")
    (halt))

(defrule MAIN::eman
  (declare (auto-focus TRUE))
  (answer (ident difference) (text yes))
  =>
  (recommend-action "u should take care about ur food")
  (halt))

  (defrule MAIN::nayra
    (declare (auto-focus TRUE))
    (answer (ident difference) (text no))
    =>
    (recommend-action "u should eat good")
    (halt))
(defrule MAIN::waleedreda
    (declare (auto-focus TRUE))
    (answer (ident which_hearts) (text Arm))
    =>
    (recommend-action "u should do rest exercise")
    (halt))
(defrule MAIN::waleedreda
    (declare (auto-focus TRUE))
    (answer (ident which_hearts) (text Leg))
    =>
    (recommend-action "u should do leg exercise")
    (halt))

(deffacts MAIN::question-data
  (question (ident what_he_want) (type multi) (valid GYM weight physical)
            (text "What do u want to know about?"))
  (question (ident register) (type multi) (valid yes no)
            (text "Does u want to register?"))
  (question (ident exercixses) (type multi) (valid yes no)
            (text "do you want to do exercise at home ?"))
  (question (ident age) (type multi) (valid yes no)
            (text "is ur age older than18?"))
  (question (ident which_hearts) (type multi) (valid Arm Leg)
            (text "what's hearts u?"))
  (question (ident difference) (type multi) (valid yes no)
            (text "is the differance between weight and height grater than 100?"))
  (ask what_he_want))

  (deffunction recommend-action (?action)
    "Give final instructions to the user"
    (call JOptionPane showMessageDialog ?*frame*
          (str-cat "I recommend that you " ?action)
          "Recommendation"
          (get-member JOptionPane INFORMATION_MESSAGE)))

  (defadvice before halt (?*qfield* setText "Close window to exit"))

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Module ask

  (defmodule ask)

  (deffunction ask-user (?question ?type ?valid)
    "Set up the GUI to ask a question"
    (?*qfield* setText ?question)
    (?*apanel* removeAll)
    (if (eq ?type multi) then
      (?*apanel* add ?*acombo*)
      (?*apanel* add ?*acombo-ok*)
      (?*acombo* removeAllItems)
      (foreach ?item ?valid
               (?*acombo* addItem ?item))
      else
      (?*apanel* add ?*afield*)
      (?*apanel* add ?*afield-ok*)
      (?*afield* setText ""))
    (?*apanel* validate)
    (?*apanel* repaint))

  (deffunction is-of-type (?answer ?type ?valid)
    "Check that the answer has the right form"
    (if (eq ?type multi) then
      (foreach ?item ?valid
               (if (eq (sym-cat ?answer) (sym-cat ?item)) then
                 (return TRUE)))
      (return FALSE))

    (if (eq ?type number) then
      (return (is-a-number ?answer)))

    ;; plain text
    (return (> (str-length ?answer) 0)))

  (deffunction is-a-number (?value)
    (try
     (integer ?value)
     (return TRUE)
     catch
     (return FALSE)))

  (defrule ask::ask-question-by-id
    "Given the identifier of a question, ask it"
    (declare (auto-focus TRUE))
    (MAIN::question (ident ?id) (text ?text) (valid $?valid) (type ?type))
    (not (MAIN::answer (ident ?id)))
    (MAIN::ask ?id)
    =>
    (ask-user ?text ?type ?valid)
    ((engine) waitForActivations))

  (defrule ask::collect-user-input
    "Check an answer returned from the GUI, and optionally return it"
    (declare (auto-focus TRUE))
    (MAIN::question (ident ?id) (text ?text) (type ?type) (valid $?valid))
    (not (MAIN::answer (ident ?id)))
    ?user <- (user-input ?input)
    ?ask <- (MAIN::ask ?id)
    =>
    (if (is-of-type ?input ?type ?valid) then
      (retract ?ask ?user)
      (assert (MAIN::answer (ident ?id) (text ?input)))
      (return)
      else
      (retract ?ask ?user)
      (assert (MAIN::ask ?id))))

  ;; Main window
  (defglobal ?*frame* = (new JFrame "Health care Expert System"))
  (?*frame* setDefaultCloseOperation (get-member JFrame EXIT_ON_CLOSE))
  (?*frame* setSize 500 250)
  (?*frame* setVisible TRUE)


  ;; Question field
  (defglobal ?*qfield* = (new JTextArea 5 40))
  (bind ?scroll (new JScrollPane ?*qfield*))
  ((?*frame* getContentPane) add ?scroll)
  (?*qfield* setText "Please wait...")

  ;; Answer area
  (defglobal ?*apanel* = (new JPanel))
  (defglobal ?*afield* = (new JTextField 40))
  (defglobal ?*afield-ok* = (new JButton OK))

  (defglobal ?*acombo* = (new JComboBox (create$ "yes" "no")))
  (defglobal ?*acombo-ok* = (new JButton OK))

  (?*apanel* add ?*afield*)
  (?*apanel* add ?*afield-ok*)
  ((?*frame* getContentPane) add ?*apanel* (get-member BorderLayout SOUTH))
  (?*frame* validate)
  (?*frame* repaint)

  (deffunction read-input (?EVENT)
    "An event handler for the user input field"
    (assert (ask::user-input (sym-cat (?*afield* getText)))))

  (bind ?handler (new jess.awt.ActionListener read-input (engine)))
  (?*afield* addActionListener ?handler)
  (?*afield-ok* addActionListener ?handler)

  (deffunction combo-input (?EVENT)
    "An event handler for the combo box"
    (assert (ask::user-input (sym-cat (?*acombo* getSelectedItem)))))

  (bind ?handler (new jess.awt.ActionListener combo-input (engine)))
  (?*acombo-ok* addActionListener ?handler)

(reset)
(run-until-halt)
