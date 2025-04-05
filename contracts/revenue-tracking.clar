;; Revenue Tracking Contract
;; This contract monitors income from various distribution channels

(define-data-var contract-owner principal tx-sender)

;; Revenue channels
(define-map revenue-channels
  { channel-id: (string-ascii 36) }
  {
    name: (string-utf8 50),
    description: (string-utf8 200),
    active: bool
  }
)

;; Revenue records
(define-map revenue-records
  {
    film-id: (string-ascii 36),
    channel-id: (string-ascii 36),
    record-id: (string-ascii 36)
  }
  {
    amount: uint,
    currency: (string-ascii 3),
    timestamp: uint,
    territory: (string-ascii 2),
    reporter: principal,
    verified: bool
  }
)

;; Film revenue totals
(define-map film-revenue-totals
  { film-id: (string-ascii 36) }
  { total-amount: uint }
)

;; Add a revenue channel
(define-public (add-revenue-channel
    (channel-id (string-ascii 36))
    (name (string-utf8 50))
    (description (string-utf8 200)))
  (let
    ((caller tx-sender))
    (asserts! (is-eq caller (var-get contract-owner)) (err u1))
    (ok (map-set revenue-channels
      { channel-id: channel-id }
      {
        name: name,
        description: description,
        active: true
      }
    ))
  )
)

;; Record revenue
(define-public (record-revenue
    (film-id (string-ascii 36))
    (channel-id (string-ascii 36))
    (record-id (string-ascii 36))
    (amount uint)
    (currency (string-ascii 3))
    (territory (string-ascii 2)))
  (let
    ((caller tx-sender)
     (channel-exists (is-some (map-get? revenue-channels { channel-id: channel-id })))
     (current-total (default-to { total-amount: u0 } (map-get? film-revenue-totals { film-id: film-id })))
     (new-total (+ amount (get total-amount current-total))))

    ;; Verify channel exists
    (asserts! channel-exists (err u2))
    ;; Verify caller is authorized reporter
    (asserts! (is-authorized-reporter caller) (err u3))

    ;; Record the revenue
    (map-set revenue-records
      {
        film-id: film-id,
        channel-id: channel-id,
        record-id: record-id
      }
      {
        amount: amount,
        currency: currency,
        timestamp: block-height,
        territory: territory,
        reporter: caller,
        verified: false
      }
    )

    ;; Update the total
    (map-set film-revenue-totals
      { film-id: film-id }
      { total-amount: new-total }
    )

    (ok true)
  )
)

;; Verify revenue record
(define-public (verify-revenue-record
    (film-id (string-ascii 36))
    (channel-id (string-ascii 36))
    (record-id (string-ascii 36)))
  (let
    ((caller tx-sender)
     (record (unwrap! (map-get? revenue-records { film-id: film-id, channel-id: channel-id, record-id: record-id }) (err u4))))

    ;; Verify caller is authorized verifier
    (asserts! (is-eq caller (var-get contract-owner)) (err u5))

    (ok (map-set revenue-records
      {
        film-id: film-id,
        channel-id: channel-id,
        record-id: record-id
      }
      (merge record { verified: true })
    ))
  )
)

;; Check if a principal is an authorized reporter
(define-read-only (is-authorized-reporter (reporter principal))
  ;; Simplified for demo - would have a more complex authorization system
  true
)

;; Get revenue record
(define-read-only (get-revenue-record (film-id (string-ascii 36)) (channel-id (string-ascii 36)) (record-id (string-ascii 36)))
  (map-get? revenue-records { film-id: film-id, channel-id: channel-id, record-id: record-id })
)

;; Get film total revenue
(define-read-only (get-film-total-revenue (film-id (string-ascii 36)))
  (default-to { total-amount: u0 } (map-get? film-revenue-totals { film-id: film-id }))
)
