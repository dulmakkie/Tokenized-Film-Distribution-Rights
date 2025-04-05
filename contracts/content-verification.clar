;; Content Verification Contract
;; This contract validates ownership of film properties

(define-data-var contract-owner principal tx-sender)

;; Film content structure
(define-map films
  { film-id: (string-ascii 36) }
  {
    owner: principal,
    title: (string-utf8 100),
    description: (string-utf8 500),
    creation-date: uint,
    hash: (buff 32),
    verified: bool
  }
)

;; Register a new film
(define-public (register-film
    (film-id (string-ascii 36))
    (title (string-utf8 100))
    (description (string-utf8 500))
    (hash (buff 32)))
  (let
    ((caller tx-sender))
    (asserts! (not (default-to false (get verified (map-get? films { film-id: film-id })))) (err u1))
    (ok (map-set films
      { film-id: film-id }
      {
        owner: caller,
        title: title,
        description: description,
        creation-date: block-height,
        hash: hash,
        verified: false
      }
    ))
  )
)

;; Verify a film's authenticity
(define-public (verify-film (film-id (string-ascii 36)))
  (let
    ((film-data (unwrap! (map-get? films { film-id: film-id }) (err u2)))
     (caller tx-sender))
    (asserts! (is-eq caller (var-get contract-owner)) (err u3))
    (ok (map-set films
      { film-id: film-id }
      (merge film-data { verified: true })
    ))
  )
)

;; Transfer film ownership
(define-public (transfer-ownership (film-id (string-ascii 36)) (new-owner principal))
  (let
    ((film-data (unwrap! (map-get? films { film-id: film-id }) (err u2)))
     (caller tx-sender))
    (asserts! (is-eq caller (get owner film-data)) (err u4))
    (ok (map-set films
      { film-id: film-id }
      (merge film-data { owner: new-owner })
    ))
  )
)

;; Check if a film is verified
(define-read-only (is-film-verified (film-id (string-ascii 36)))
  (default-to false (get verified (map-get? films { film-id: film-id })))
)

;; Get film details
(define-read-only (get-film-details (film-id (string-ascii 36)))
  (map-get? films { film-id: film-id })
)
