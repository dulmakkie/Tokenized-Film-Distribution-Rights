;; Territory Rights Contract
;; This contract manages distribution permissions by region

(define-data-var contract-owner principal tx-sender)

;; Territory codes (ISO 3166-1 alpha-2)
(define-map territory-codes
  { code: (string-ascii 2) }
  { name: (string-utf8 50) }
)

;; Film territory rights
(define-map territory-rights
  {
    film-id: (string-ascii 36),
    territory: (string-ascii 2)
  }
  {
    rights-holder: principal,
    start-date: uint,
    end-date: uint,
    exclusive: bool
  }
)

;; Initialize territory codes
(define-public (add-territory-code (code (string-ascii 2)) (name (string-utf8 50)))
  (let
    ((caller tx-sender))
    (asserts! (is-eq caller (var-get contract-owner)) (err u1))
    (ok (map-set territory-codes
      { code: code }
      { name: name }
    ))
  )
)

;; Grant territory rights
(define-public (grant-territory-rights
    (film-id (string-ascii 36))
    (territory (string-ascii 2))
    (rights-holder principal)
    (start-date uint)
    (end-date uint)
    (exclusive bool))
  (let
    ((caller tx-sender)
     (territory-exists (is-some (map-get? territory-codes { code: territory }))))
    ;; Verify territory exists
    (asserts! territory-exists (err u2))
    ;; Verify caller is authorized (would typically check against content verification contract)
    (asserts! (is-authorized caller film-id) (err u3))
    ;; Verify dates are valid
    (asserts! (< start-date end-date) (err u4))
    ;; If exclusive, check no overlapping rights exist
    (asserts! (or (not exclusive) (can-grant-exclusive film-id territory start-date end-date)) (err u5))

    (ok (map-set territory-rights
      {
        film-id: film-id,
        territory: territory
      }
      {
        rights-holder: rights-holder,
        start-date: start-date,
        end-date: end-date,
        exclusive: exclusive
      }
    ))
  )
)

;; Check if a principal is authorized for a film
;; In a real implementation, this would check against the content verification contract
(define-read-only (is-authorized (caller principal) (film-id (string-ascii 36)))
  ;; Simplified for demo - would call content verification contract
  (is-eq caller (var-get contract-owner))
)

;; Check if exclusive rights can be granted (no overlapping exclusive rights)
(define-read-only (can-grant-exclusive (film-id (string-ascii 36)) (territory (string-ascii 2)) (start-date uint) (end-date uint))
  ;; Simplified check - in reality would need to query all rights for this territory/film
  ;; and check for date overlaps
  (is-none (map-get? territory-rights { film-id: film-id, territory: territory }))
)

;; Get territory rights
(define-read-only (get-territory-rights (film-id (string-ascii 36)) (territory (string-ascii 2)))
  (map-get? territory-rights { film-id: film-id, territory: territory })
)

;; Check if distribution is allowed
(define-read-only (can-distribute (film-id (string-ascii 36)) (territory (string-ascii 2)) (distributor principal) (current-time uint))
  (match (map-get? territory-rights { film-id: film-id, territory: territory })
    rights (and
             (is-eq distributor (get rights-holder rights))
             (>= current-time (get start-date rights))
             (<= current-time (get end-date rights)))
    false
  )
)
