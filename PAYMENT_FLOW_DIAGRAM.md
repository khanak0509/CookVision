# 🔄 Payment Flow Visualization

```
┌─────────────────────────────────────────────────────────────────────┐
│                        RAZORPAY PAYMENT FLOW                         │
└─────────────────────────────────────────────────────────────────────┘

                            USER JOURNEY
                            ════════════

    📱 Cart Screen               📋 Checkout Screen
    ┌──────────────┐            ┌──────────────────┐
    │ Items: 3     │            │ Cart Items       │
    │ Total: ₹450  │  ────────> │ Delivery Address │
    │              │            │ Price Summary    │
    │ [Checkout] ──┼────────────│ [Pay ₹540] ─────┤
    └──────────────┘            └──────────────────┘
                                         │
                                         ▼
                                ┌─────────────────┐
                                │ Razorpay Modal  │
                                │ Card: 4111...   │
                                │ CVV: 123        │
                                │ [Pay Now] ──────┤
                                └─────────────────┘
                                         │
                                         ▼
                                ┌─────────────────┐
                                │ ✅ Success      │
                                │ Order ID: xxx   │
                                │ Payment ID: pay │
                                │ [Home] ─────────┤
                                └─────────────────┘


                         TECHNICAL FLOW
                         ══════════════

┌──────────┐                                              ┌──────────┐
│          │  1. User adds items to cart                  │          │
│  Flutter │  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━>  │ Firebase │
│   App    │                                              │ Firestore│
│          │  2. User clicks "Checkout"                   │          │
│          │  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━>  │          │
└────┬─────┘                                              └──────────┘
     │
     │ 3. Navigate to CheckoutScreen
     │    (shows cart items, address input)
     │
     │ 4. User clicks "Pay ₹540"
     │
     ▼
┌──────────┐
│          │  5. POST /api/razorpay/create-order
│  Flutter │  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━>  ┌──────────┐
│   App    │                                        │  Python  │
│          │  { amount, order_id, user_id }        │  FastAPI │
│          │                                        │ Backend  │
│          │  <━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │          │
│          │  6. { razorpay_order_id }             └────┬─────┘
│          │                                             │
│          │                                             │ 5a. Create order
│          │                                             │     in Razorpay
│          │                                             ▼
│          │                                        ┌──────────┐
│          │                                        │ Razorpay │
│          │                                        │   API    │
│          │                                        │          │
│          │                                        └────┬─────┘
│          │                                             │
│          │                                             │ 5b. Order created
│          │                                             │     order_xxx
│          │                                             ▼
│          │                                        ┌──────────┐
│          │  5c. Store in payment_orders           │ Firebase │
│          │     collection                         │ Firestore│
│          │     <━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   │          │
│          │                                        └──────────┘
│          │
│          │ 7. Open Razorpay Checkout
│          │    (modal with payment form)
│          │
│          │ 8. User enters card details
│          │    and completes payment
│          │
│          │ 9. Razorpay processes payment
│          │    ━━━━━━━━━━━━━━━━━━━━━━━━━━━>  ┌──────────┐
│          │                                    │ Razorpay │
│          │                                    │   SDK    │
│          │  <━━━━━━━━━━━━━━━━━━━━━━━━━━━━   │          │
│          │  10. Payment callback              └──────────┘
│          │      { payment_id, order_id,
│          │        signature }
│          │
│          │ 11. POST /api/razorpay/verify-payment
│          │  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━>  ┌──────────┐
│          │  { payment_id, order_id, signature } │  Python  │
│          │                                      │  FastAPI │
│          │                                      │ Backend  │
│          │                                      └────┬─────┘
│          │                                           │
│          │                                           │ 11a. Verify signature
│          │                                           │      using HMAC SHA256
│          │                                           │
│          │                                           │ 11b. Update payment_orders
│          │                                           │      status = 'paid'
│          │                                           ▼
│          │                                      ┌──────────┐
│          │  11c. Update order                   │ Firebase │
│          │      payment_status = 'paid'         │ Firestore│
│          │      <━━━━━━━━━━━━━━━━━━━━━━━━━━━   │          │
│          │                                      └──────────┘
│          │
│          │  <━━━━━━━━━━━━━━━━━━━━━━━━━━━━
│          │  12. { verified: true }
│          │
│          │ 13. Clear cart items
│          │  ━━━━━━━━━━━━━━━━━━━━━━━━━━━>  ┌──────────┐
│          │                                  │ Firebase │
│          │                                  │ Firestore│
│          │                                  │          │
│          │  14. Navigate to                 └──────────┘
│          │      OrderSuccessScreen
│          │
│          │  15. Show Order ID & Payment ID
│          │      ✅ Payment Successful!
│          │
└──────────┘


                         SECURITY LAYER
                         ══════════════

┌─────────────────────────────────────────────────────────────┐
│  HMAC SHA256 Signature Verification                         │
│  ═══════════════════════════════════════════════════════    │
│                                                              │
│  Backend calculates:                                        │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ generated_signature = hmac.new(                     │   │
│  │     RAZORPAY_KEY_SECRET,                            │   │
│  │     f"{order_id}|{payment_id}",                     │   │
│  │     hashlib.sha256                                  │   │
│  │ ).hexdigest()                                       │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                              │
│  Compare:                                                   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ if generated_signature == razorpay_signature:       │   │
│  │     ✅ PAYMENT VERIFIED                             │   │
│  │ else:                                               │   │
│  │     ❌ PAYMENT TAMPERED - REJECT                    │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                              │
└─────────────────────────────────────────────────────────────┘


                    FIREBASE DATA STRUCTURE
                    ════════════════════════

users/
  {userId}/
    cart_items/              ← Cleared after successful payment
      {doc_id}/
        - name: "Butter Chicken"
        - price: 250
        - quantity: 2
        - emoji: "🍗"

    orders/                  ← Order created before payment
      {order_id}/
        - order_id: "1702584000000"
        - items: [...]
        - total_amount: 500
        - delivery_address: "123 Street..."
        - payment_status: "pending" → "paid" ✅
        - order_status: "pending" → "confirmed" ✅
        - payment_id: "pay_xxx"
        - razorpay_order_id: "order_xxx"
        - created_at: timestamp

payment_orders/              ← Global payment tracking
  {razorpay_order_id}/
    - razorpay_order_id: "order_xxx"
    - app_order_id: "1702584000000"
    - user_id: "user_xxx"
    - amount: 500.00
    - currency: "INR"
    - status: "created" → "paid" ✅
    - payment_id: "pay_xxx"      ← Added after payment
    - signature: "xxx"            ← Added after verification
    - created_at: timestamp
    - updated_at: timestamp


                        ERROR HANDLING
                        ══════════════

Payment Failed
│
├─> Network Error
│   └─> Retry payment
│   └─> Order status: "pending"
│   └─> Cart preserved
│
├─> Invalid Card
│   └─> User enters new card
│   └─> Order status: "pending"
│   └─> Cart preserved
│
├─> Signature Verification Failed
│   └─> Payment not accepted
│   └─> Order status: "failed"
│   └─> Manual reconciliation needed
│
└─> User Cancelled
    └─> Return to checkout
    └─> Order status: "cancelled"
    └─> Cart preserved


                    SUCCESS INDICATORS
                    ══════════════════

✅ payment_orders.status = "paid"
✅ orders.payment_status = "paid"
✅ orders.order_status = "confirmed"
✅ cart_items collection = empty
✅ Razorpay dashboard shows "captured"
✅ User sees success screen


                      TEST VS LIVE
                      ════════════

┌─────────────────┬────────────────────┬────────────────────┐
│   Environment   │     Test Mode      │     Live Mode      │
├─────────────────┼────────────────────┼────────────────────┤
│ Key ID starts   │ rzp_test_xxxxx     │ rzp_live_xxxxx     │
│ with            │                    │                    │
├─────────────────┼────────────────────┼────────────────────┤
│ Payment cards   │ 4111 1111 1111     │ Real cards only    │
│                 │ 1111 (test)        │                    │
├─────────────────┼────────────────────┼────────────────────┤
│ Real money      │ ❌ No              │ ✅ Yes             │
├─────────────────┼────────────────────┼────────────────────┤
│ Dashboard       │ Test transactions  │ Real transactions  │
│                 │ visible            │ visible            │
├─────────────────┼────────────────────┼────────────────────┤
│ KYC Required    │ ❌ No              │ ✅ Yes             │
└─────────────────┴────────────────────┴────────────────────┘
```
