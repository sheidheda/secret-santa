;; Secret Santa Gift Exchange Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-not-authorized (err u100))
(define-constant err-already-registered (err u101))
(define-constant err-invalid-amount (err u102))
(define-constant err-not-registered (err u103))
(define-constant err-already-paired (err u104))
(define-constant err-not-reveal-time (err u105))
(define-constant err-already-claimed (err u106))
(define-constant err-not-enough-participants (err u107))
(define-constant err-pairing-failed (err u108))

;; Data Variables
(define-data-var registration-open bool true)
(define-data-var reveal-time uint u1703462400) ;; Set to December 24, 2024, 00:00:00 UTC
(define-data-var minimum-participants uint u3)
(define-data-var minimum-contribution uint u100)
(define-data-var participant-count uint u0)
(define-data-var current-pair-index uint u0)

;; Data Maps
(define-map participants principal 
  {
    registered: bool,
    contribution: uint,
    paired: bool,
    gift-claimed: bool,
    index: uint
  }
)

(define-map participant-indices uint principal)
(define-map santa-pairs principal principal) ;; Giver -> Receiver
(define-map gift-receivers principal principal) ;; Receiver -> Giver

;; Private Functions
(define-private (is-registered (user principal))
  (default-to false (get registered (map-get? participants user)))
)

(define-private (get-contribution (user principal))
  (default-to u0 (get contribution (map-get? participants user)))
)

(define-private (is-paired (user principal))
  (default-to false (get paired (map-get? participants user)))
)


;; Public Functions
(define-public (register-participant (contribution uint))
  (let (
    (caller tx-sender)
    (current-count (var-get participant-count))
  )
    (asserts! (var-get registration-open) err-already-paired)
    (asserts! (>= contribution (var-get minimum-contribution)) err-invalid-amount)
    (asserts! (not (is-registered caller)) err-already-registered)
    
    (try! (stx-transfer? contribution caller (as-contract tx-sender)))
    
    (map-set participants caller {
      registered: true,
      contribution: contribution,
      paired: false,
      gift-claimed: false,
      index: current-count
    })
    
    (map-set participant-indices current-count caller)
    (var-set participant-count (+ current-count u1))
    
    (ok true))
)

(define-public (pair-single-participant)
  (let (
    (caller tx-sender)
    (total-participants (var-get participant-count))
    (current-index (var-get current-pair-index))
  )
    (asserts! (is-contract-owner) err-not-authorized)
    (asserts! (>= total-participants (var-get minimum-participants)) err-not-enough-participants)
    (asserts! (< current-index total-participants) err-pairing-failed)
    
    (let (
      (current-participant (unwrap! (map-get? participant-indices current-index) err-pairing-failed))
      (next-index (mod (+ current-index u1) total-participants))
      (next-participant (unwrap! (map-get? participant-indices next-index) err-pairing-failed))
    )
      ;; Create pairing
      (map-set santa-pairs current-participant next-participant)
      (map-set gift-receivers next-participant current-participant)
      
      ;; Update participant status
      (map-set participants current-participant 
        (merge (unwrap! (map-get? participants current-participant) err-not-registered)
          { paired: true }))
      
      ;; Update index for next pairing
      (var-set current-pair-index (+ current-index u1))
      
      ;; Close registration if all participants are paired
      (if (is-eq (+ current-index u1) total-participants)
        (var-set registration-open false)
        true)
      
      (ok true)))
)

(define-public (reveal-gift)
  (let ((caller tx-sender))
    (asserts! (>= block-height (var-get reveal-time)) err-not-reveal-time)
    (asserts! (is-registered caller) err-not-registered)
    (asserts! (is-paired caller) err-already-paired)
    
    (ok (unwrap! (map-get? gift-receivers caller) err-not-registered)))
)

(define-public (claim-gift)
  (let (
    (caller tx-sender)
    (participant-data (unwrap! (map-get? participants caller) err-not-registered))
  )
    (asserts! (>= block-height (var-get reveal-time)) err-not-reveal-time)
    (asserts! (not (get gift-claimed participant-data)) err-already-claimed)
    
    (let ((santa (unwrap! (map-get? gift-receivers caller) err-not-registered)))
      (try! (as-contract (stx-transfer? 
        (get contribution (unwrap! (map-get? participants santa) err-not-registered))
        tx-sender
        caller)))
      
      (map-set participants caller 
        (merge participant-data { gift-claimed: true }))
      
      (ok true)))
)

(define-public (withdraw-contribution)
  (let (
    (caller tx-sender)
    (participant-data (unwrap! (map-get? participants caller) err-not-registered))
  )
    (asserts! (var-get registration-open) err-already-paired)
    (asserts! (not (get paired participant-data)) err-already-paired)
    
    (try! (as-contract (stx-transfer? 
      (get contribution participant-data)
      tx-sender
      caller)))
    
    (map-delete participants caller)
    (var-set participant-count (- (var-get participant-count) u1))
    (ok true))
)

;; Read-only Functions
(define-read-only (get-participant-info (participant principal))
  (map-get? participants participant)
)

(define-read-only (is-contract-owner)
  (is-eq tx-sender contract-owner)
)

(define-read-only (get-participant-count)
  (var-get participant-count)
)

(define-read-only (get-current-pair-index)
  (var-get current-pair-index)
)