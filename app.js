const $ = (s, r = document) => r.querySelector(s),
  $$ = (s, r = document) => [...r.querySelectorAll(s)];
const money = (n) =>
  new Intl.NumberFormat("de-AT", {
    style: "currency",
    currency: "EUR",
    maximumFractionDigits: 0,
  }).format(n);
const state = {
  module: "home",
  bookStep: 1,
  service: "",
  price: 0,
  barber: "",
  time: "",
  addon: 0,
  tip: 0,
  plan: "prepared",
  target: 25000,
  current: 21140,
  forecast: 23680,
  gap: 1320,
  opportunity: 1740,
  impact: 3320,
  appointments: 312,
  filled: 12,
  recoveredCustomers: 19,
  ownerHours: 13.8,
  liveSlotFilled: false,
  waitlistInvited: false,
  ownerPaymentRecorded: false,
  coreTab: "booking",
  recurringCreated: false,
  groupCreated: false,
  formSent: false,
  manualBooking: false,
  refundPending: false,
  poPrepared: false,
  loyaltyPoints: 420,
  packageCredits: 3,
  giftBalance: 65,
  guestBooking: null,
  guestDeposit: 0,
  guestPaymentStatus: "none",
  guestWaitlist: false,
  guestReview: false,
  guestMembership: false,
  guestGift: false,
  futureBooking: null,
  guestEvents: [],
  guestLang: "DE",
  cutMemory: { service:"Skin Fade", barber:"Demo Barber A", time:"16:15" },
  permissions: {
    marketing: true,
    discount: true,
    waitlist: true,
    rebooking: true,
    reviews: true,
    reactivation: true,
    inventory: false,
    refund: false,
    schedule: false,
    price: false,
  },
};

const STORAGE_KEY="operator-demo-state-v2";
const PERSIST_KEYS=["plan","target","current","forecast","gap","opportunity","impact","appointments","filled","recoveredCustomers","ownerHours","liveSlotFilled","waitlistInvited","ownerPaymentRecorded","recurringCreated","groupCreated","formSent","manualBooking","refundPending","poPrepared","loyaltyPoints","packageCredits","giftBalance","guestBooking","guestDeposit","guestPaymentStatus","guestWaitlist","guestReview","guestMembership","guestGift","futureBooking","guestLang","cutMemory","guestEvents"];
function saveDemoState(){
  const safe={}; PERSIST_KEYS.forEach(k=>safe[k]=state[k]);
  try{localStorage.setItem(STORAGE_KEY,JSON.stringify(safe))}catch(e){}
}
function loadDemoState(){
  try{const saved=JSON.parse(localStorage.getItem(STORAGE_KEY)||"null");if(saved)Object.assign(state,saved)}catch(e){}
}
function clearDemoState(){try{localStorage.removeItem(STORAGE_KEY);localStorage.removeItem("operator-demo-state-v1")}catch(e){}}
loadDemoState();
const titles = {
  home: ["Home", "Executive overview · September 2026"],
  operator: ["AI Operator", "Goal-driven plan · owner approval required"],
  live: ["Live Business", "Real-time capacity and decision-required events"],
  calendar: ["Calendar", "Appointments, waitlist and capacity"],
  customers: [
    "Customer Intelligence",
    "Value, behavior, risk and next best action",
  ],
  staff: ["Staff Intelligence", "Capacity, economics and actionable growth"],
  goals: ["Goals", "Tell the system what outcomes matter"],
  autopilot: ["Autopilot", "Rules, permissions and approval thresholds"],
  memory: ["Business Memory", "What the system learned from actual outcomes"],
  simulator: ["Ask Your Business", "Scenario modeling · demo / simulated data"],
  core: [
    "Business Core",
    "Complete platform · AI-first, manual always available",
  ],
  money: ["Money", "Checkout, payments and financial reporting"],
  grow: ["Grow", "Automated growth and marketing"],
  inventory: ["Inventory", "Stock, retail and purchasing"],
  locations: ["Locations", "Owner-level multi-location intelligence"],
  impact: ["Impact", "Traceable attributed business outcomes"],
  decisions: ["Decision Log", "Every AI action, reason, cost and result"],
  settings: ["Settings", "Business core, integrations and data protection · demo state persists locally"],
};
function toast(t, x = "") {
  let e = $("#toast");
  $("#toastTitle").textContent = t;
  $("#toastText").textContent = x;
  e.classList.remove("hidden");
  clearTimeout(window.tt);
  window.tt = setTimeout(() => e.classList.add("hidden"), 3400);
}
function setView(id) {
  $$(".view").forEach((v) => v.classList.toggle("hidden", v.id !== id));
  $$("[data-view]").forEach((b) => b.classList.toggle("active", b.dataset.view === id));
  window.scrollTo({ top: 0, behavior: "smooth" });
}
// Delegated navigation is resilient to rerenders and mobile Safari event quirks.
document.addEventListener("click", (e) => {
  const target = e.target instanceof Element ? e.target : e.target.parentElement;
  if (!target) return;
  const viewButton = target.closest("[data-view]");
  if (viewButton) { e.preventDefault(); setView(viewButton.dataset.view); return; }
  const moduleButton = target.closest("[data-module]");
  if (moduleButton) { e.preventDefault(); renderModule(moduleButton.dataset.module); return; }
}, true);
function schedule() {
  return '<div class="schedule"><div></div><div class="shead">Demo Barber B</div><div class="shead">Demo Barber A</div><div class="shead">Demo Barber C</div><div class="hour">10:00</div><div class="appt" data-action="appointment"><b>Demo Guest A · Cut</b><small>10:00–10:45</small></div><div></div><div class="appt blue" data-action="appointment"><b>Demo Risk Guest A · Fade</b><small>10:00–10:50</small></div><div class="hour">11:00</div><div></div><div class="appt sand" data-action="appointment"><b>Demo Guest B · Beard</b><small>11:15–11:45</small></div><div></div><div class="hour">12:00</div><div class="appt blue" data-action="appointment"><b>Demo Guest C · Combo</b><small>12:00–13:00</small></div><div></div><div class="appt" data-action="appointment"><b>Demo Guest D · Cut</b><small>12:15–13:00</small></div><div class="hour">14:00</div><div class="appt sand" data-action="appointment"><b>Demo Guest E · Fade</b><small>14:00–14:50</small></div><div class="appt blue" data-action="appointment"><b>Demo Guest F · Cut</b><small>14:00–14:45</small></div><div class="appt risk" data-action="appointment"><b>Demo Risk Guest · Combo</b><small>AI risk · 14:30</small></div></div>';
}
function calendar() {
  let rows = [
    ["10:00", "Demo Guest A · Classic Cut", "", "Demo Risk Guest A · Skin Fade"],
    ["11:00", "", "Demo Guest B · Beard", ""],
    ["12:00", "Demo Guest C · Combo", "", "Demo Guest D · Cut"],
    ["13:00", "Lunch", "Lunch", "Lunch"],
    ["14:00", "Demo Guest E · Skin Fade", "Demo Guest F · Classic Cut", "Demo Risk Guest · Combo"],
    ["15:00", "Demo Guest G · Undercut", "AI gap · €42", ""],
    ["16:00", "Demo Guest H · Cut", "Demo Guest I · Fade", "Demo Guest J · Beard"],
    ["17:00", "", "Demo Guest K · Cut", "Demo Guest L · Combo"],
  ];
  if (state.guestBooking && state.guestBooking.status !== "Cancelled") {
    const label = "DEMO GUEST · " + state.guestBooking.service + " · €" + state.guestBooking.price;
    const hour = (state.guestBooking.time || "16:00").slice(0,2) + ":00";
    const row = rows.find(r => r[0] === hour);
    if (row) {
      const col = state.guestBooking.barber.includes("B") ? 1 : state.guestBooking.barber.includes("C") ? 3 : 2;
      row[col] = label;
    } else rows.push([hour,"",label,""]);
  }
  if (state.futureBooking && state.futureBooking.status !== "Cancelled") {
    const label = "FUTURE DEMO · " + state.futureBooking.service + " · €" + state.futureBooking.price;
    rows.push(["20:00","",label,""]);
  }
  let h =
    '<div class="calendar-grid"><div></div><div class="calhead"><b>Demo Barber B</b><small>84% · €248</small></div><div class="calhead"><b>Demo Barber A</b><small>91% · €294</small></div><div class="calhead"><b>Demo Barber C</b><small>72% · €142</small></div>';
  rows.forEach((r) => {
    h += '<div class="cal-time">' + r[0] + "</div>";
    r.slice(1).forEach((x, i) => {
      h += x
        ? '<div class="cal-card ' +
          (x.includes("gap") ? "gap" : i === 1 ? "blue" : "") +
          " " +
          (x.includes("Demo Risk Guest") ? "risk" : "") + (x.includes("DEMO GUEST") ? " demo-guest" : "") +
          '" data-action="' +
          (x.includes("gap") ? "fill-gap" : "appointment") +
          '"><b>' +
          x +
          "</b><small>" +
          (x.includes("gap") ? "6 waitlist match" : "Open details") +
          "</small></div>"
        : "<div></div>";
    });
  });
  return h + "</div>";
}
const modules = {
  today: () =>
    '<section class="ai-brief"><div><span class="spark">✦ AI DAILY BRIEF</span><h2>3 decisions can protect +€286 revenue today.</h2><p>The Operator analyzed bookings, customer cycles and empty-chair capacity.</p></div><div class="brief-points"><span>15:30 empty slot can be filled from the waitlist</span><span>2 high-risk bookings need confirmation</span><span>14 customerss are due for rebooking</span></div><button data-action="run-brief">Execution plan →</button></section><div class="grid-4"><article class="kpi"><span>TODAY\'S BOOKINGS</span><b>17</b><small>+3 vs yesterday</small></article><article class="kpi"><span>EXPECTED REVENUE</span><b>€684</b><small>82% utilization</small></article><article class="kpi"><span>RETURNING</span><b>71%</b><small>+8% vs last month</small></article><article class="kpi"><span>PROTECTED REVENUE</span><b>€104</b><small>no-show protection</small></article></div><div class="content-grid"><section class="panel"><div class="panel-head"><h2>Today\'s chair plan</h2><button data-go="calendar">Full calendar →</button></div>' +
    schedule() +
    '</section><div class="side-stack"><section class="panel opportunity"><small>EMPTY CHAIR OPPORTUNITY</small><b class="amount">€42</b><p>6 suitable customers match Demo Barber A\'s 15:30 slot.</p><button data-action="fill-gap">Fill slot with AI</button></section><section class="panel"><div class="panel-head"><h2>Live activity</h2><small>now</small></div><div class="activity-list"><div class="activity-row"><i></i><div><b>New booking</b><small>Demo Guest F · Classic Cut · Demo Barber A</small></div><time>2p</time></div><div class="activity-row"><i></i><div><b>Card pre-authorized</b><small>Demo Risk Guest A · higher risk</small></div><time>18p</time></div><div class="activity-row"><i></i><div><b>5★ review</b><small>„Perfekt wie immer”</small></div><time>1h</time></div></div></section><section class="panel"><div class="panel-head"><h2>Walk-in queue</h2><button data-action="add-walkin">+ Customer</button></div><div class="walkin"><span><b>Demo Walk-in A</b><small>Skin Fade · 12 min</small></span><b>Demo Barber A</b></div><div class="walkin"><span><b>Walk-in #18</b><small>Classic Cut · 28 min</small></span><b>Demo Barber B</b></div></section></div></div>',
  calendar: () =>
    '<div class="section-bar"><div><h2>Calendar · September 22</h2><small class="muted">3 barber · 82% utilization</small></div><div class="filters"><button class="active">Day</button><button>Week</button><button>List</button><button data-action="add-block">+ Block</button></div></div><div class="calendar-board">' +
    calendar() +
    '</div><div class="content-grid"><section class="panel"><div class="panel-head"><h2>Smart waitlist</h2><small>6 customerss · real-time ranking</small></div><table class="table"><thead><tr><th>CUSTOMER</th><th>SERVICE</th><th>AVAILABILITY</th><th>AI MATCH</th><th></th></tr></thead><tbody><tr><td><b>Demo Waitlist Guest A</b></td><td>Skin Fade</td><td>14:00–18:00</td><td><span class="badge">96%</span></td><td><button class="ghost" data-action="invite-waitlist">Invite</button></td></tr><tr><td><b>Demo Waitlist Guest B</b></td><td>Classic Cut</td><td>after 15:00</td><td><span class="badge">91%</span></td><td><button class="ghost" data-action="invite-waitlist">Invite</button></td></tr></tbody></table></section><section class="panel"><div class="panel-head"><h2>Capacity forecast</h2><span class="badge blue">AI FORECAST</span></div><p class="muted">Friday 16:00–19:00 is over capacity; Wednesday morning has 31% spare capacity.</p><button class="primary small" data-action="capacity">Open staffing suggestion</button></section></div>',
  customers: () =>
    '<div class="section-bar"><div><h2>Customers</h2><small class="muted">1,284 profiles · 71% returning</small></div><div class="filters"><button class="active">All</button><button>Due 28</button><button>At risk 9</button><button>VIP 42</button></div></div><div class="customer-layout"><section class="customer-list"><div class="list-search"><input placeholder="Search customers…"></div><div class="client-row active"><span class="avatar dark">LM</span><div><b>Demo Customer</b><small>VIP · 12 visits · €624</small></div></div><div class="client-row"><span class="avatar lime">MF</span><div><b>Demo Customer B</b><small>Due 4 days ago · €288</small></div></div><div class="client-row"><span class="avatar sand">PN</span><div><b>Demo Customer C</b><small>At-risk · No visit for 9 weeks</small></div></div><div class="client-row"><span class="avatar pale">JW</span><div><b>Demo Customer D</b><small>New customer · 1 visit</small></div></div></section><section class="customer-profile"><div class="profile-top"><div class="profile-name"><span class="avatar dark">LM</span><div><h2>Demo Customer</h2><p>VIP · Demo Barber A client · Last visit: Aug 28</p></div></div><div class="profile-actions"><button class="ghost" data-action="message-client">Message</button><button class="primary small" data-action="rebook-client">Rebook</button></div></div><div class="profile-body"><div class="profile-stats"><div class="mini-stat"><span>VISITS</span><b>12</b></div><div class="mini-stat"><span>TOTAL SPEND</span><b>€624</b></div><div class="mini-stat"><span>AVG CYCLE</span><b>25 days</b></div><div class="mini-stat"><span>NO-SHOW</span><b>0</b></div></div><section class="cut-memory"><div class="cut-head"><div><span>✦ CUT MEMORY · AI SUMMARY</span><h3>Demo Customer preferred cut</h3></div><span>Updated Aug 28</span></div><div class="cut-specs"><div><small>SIDES</small><b>0 → 1.5 skin fade</b></div><div><small>TOP</small><b>5 cm, textured</b></div><div><small>BLEND</small><b>Low–mid, soft</b></div><div><small>BEARD</small><b>6 mm, sharp line</b></div><div><small>PRODUCT</small><b>Matte Clay</b></div><div><small>NOTE</small><b>Keep natural crown</b></div></div></section><div class="timeline"><h3>Visit timeline</h3><div class="visit"><b>aug. 28.</b><span><b>Skin Fade + Beard · Demo Barber A</b><small>5★ · Matte Clay purchase</small></span><b>€64</b></div><div class="visit"><b>aug. 02.</b><span><b>Skin Fade · Demo Barber A</b><small>Cut Memory updated</small></span><b>€42</b></div></div></div></section></div>',
  staff: () =>
    '<div class="section-bar"><div><h2>Team & performance</h2><small class="muted">Shifts, permissions, commissions and goals</small></div><button class="primary small" data-action="add-staff">+ Staff</button></div><table class="table"><thead><tr><th>BARBER</th><th>TODAY</th><th>UTILIZATION</th><th>30D REVENUE</th><th>REBOOKING</th><th>RATING</th></tr></thead><tbody><tr><td><b>Demo Barber A</b><br><span class="muted">Fade specialist</span></td><td>7 customers</td><td><span class="badge">91%</span></td><td>€5,840</td><td>78%</td><td>4,9 ★</td></tr><tr><td><b>Demo Barber B</b><br><span class="muted">Senior barber</span></td><td>6 customers</td><td><span class="badge">84%</span></td><td>€5,260</td><td>74%</td><td>4,9 ★</td></tr><tr><td><b>Demo Barber C</b><br><span class="muted">Barber & stylist</span></td><td>4 customers</td><td><span class="badge blue">72%</span></td><td>€4,110</td><td>66%</td><td>4,8 ★</td></tr></tbody></table><div class="content-grid"><section class="panel"><div class="panel-head"><h2>AI Performance Coach</h2><span class="badge blue">WEEKLY</span></div><p>Demo Barber A performs strongly on fade-customer retention. Demo Barber C\'s chair-side rebooking is 11% below the demo business average.</p><button class="primary small" data-action="coach">Personal coaching plan</button></section><section class="panel"><div class="panel-head"><h2>Upcoming shifts</h2></div><div class="walkin"><span><b>Wednesday</b><small>10:00–20:00</small></span><b>3 barber</b></div><div class="walkin"><span><b>Thursday</b><small>10:00–20:00</small></span><b>3 barber</b></div></section></div>',
  money: () =>
    '<div class="section-bar"><div><h2>Checkout · Demo Customer</h2><small class="muted">Skin Fade + Beard · Demo Barber A · 16:15</small></div><div class="filters"><button>Daily close</button><button>Transactions</button><button>Reports</button></div></div><div class="checkout"><section class="receipt"><h2>Items</h2><div class="line-item"><span><b>Skin Fade + Beard</b><small class="muted">60 min · Demo Barber A</small></span><b>€52</b></div><div class="line-item addon-line hidden"><span><b>NOIR Matte Clay</b><small class="muted">AI suggestion · 100 ml</small></span><b>€18</b></div><div class="addon"><span><b>✦ Smart add-on</b><br><small class="muted">Demo Customer bought Matte Clay on the previous visit.</small></span><button data-action="add-product">+ €18</button></div><div class="total-line"><span>Total</span><b id="checkoutTotal">€52</b></div></section><aside class="pay-panel"><h2>Payment</h2><small class="muted">Tip</small><div class="tip-row"><button class="active" data-tip="0">None</button><button data-tip="5">5%</button><button data-tip="10">10%</button><button data-tip="15">15%</button></div><div class="payment-methods"><button class="active">◉ Tap to Pay</button><button>▣ Cash</button><button>↗ Payment link</button><button>◇ Gift card</button></div><button class="pay-now" data-action="pay">Pay · <span id="payAmount">€52</span></button><p class="muted" style="font-size:.68rem">Receipt, commission and inventory update automatically.</p></aside></div>',
  grow: () =>
    '<div class="section-bar"><div><h2>Growth Center</h2><small class="muted">Segments, automations, campaigns and reviews</small></div><button class="primary small" data-action="new-campaign">+ Campaign</button></div><div class="campaign-grid"><article class="campaign"><span class="tag">✦ AI REACTIVATION</span><h3>9 at-risk customers</h3><p>No return for 6–10 weeks despite being due based on their previous cycle.</p><span class="estimate">+€286</span><small>estimated revenue</small><button data-action="campaign">Prepare campaign</button></article><article class="campaign"><span class="tag">EMPTY CHAIR</span><h3>Demo Barber A · today 15:30</h3><p>Demo Waitlist Guest is the highest-ranked match among 6 waitlist customers.</p><span class="estimate">+€42</span><small>recoverable</small><button data-action="fill-gap">Send invite</button></article><article class="campaign"><span class="tag">REVIEWS</span><h3>14 review requests ready</h3><p>Happy returning customers with personalized review links.</p><span class="estimate">4.9 ★</span><small>current average</small><button data-action="reviews">Start review flow</button></article></div><div class="content-grid"><section class="panel"><div class="panel-head"><h2>Active automations</h2><button>All</button></div><table class="table"><tr><td><b>25-day rebooking reminder</b></td><td><span class="badge">ACTIVE</span></td><td>€724 / 30 days</td></tr><tr><td><b>No-show confirmation</b></td><td><span class="badge">ACTIVE</span></td><td>€312 protected</td></tr><tr><td><b>Birthday offer</b></td><td><span class="badge">ACTIVE</span></td><td>18 bookings</td></tr></table></section><section class="panel"><div class="panel-head"><h2>Channels</h2></div><div class="walkin"><span><b>SMS</b><small>98.7% delivery</small></span><span class="badge">ACTIVE</span></div><div class="walkin"><span><b>WhatsApp</b><small>Human handoff enabled</small></span><span class="badge">ACTIVE</span></div><div class="walkin"><span><b>Email</b><small>Branded template</small></span><span class="badge">ACTIVE</span></div></section></div>',
  inventory: () =>
    '<div class="section-bar"><div><h2>Inventory & products</h2><small class="muted">48 products · 2 reorder alerts</small></div><button class="primary small" data-action="stock-order">New order</button></div><table class="table"><thead><tr><th>PRODUCT</th><th>STOCK</th><th>SALES / 30D</th><th>MARGIN</th><th>FORECAST</th><th></th></tr></thead><tbody><tr><td><b>NOIR Matte Clay</b></td><td>18 units</td><td>24 units</td><td>61%</td><td><span class="badge">21 days</span></td><td><button class="ghost">Details</button></td></tr><tr><td><b>Beard Oil Cedar</b></td><td>5 units</td><td>13 units</td><td>58%</td><td><span class="badge red">8 days</span></td><td><button class="ghost" data-action="reorder">Reorder</button></td></tr><tr><td><b>Sea Salt Spray</b></td><td>7 units</td><td>11 units</td><td>54%</td><td><span class="badge red">12 days</span></td><td><button class="ghost" data-action="reorder">Reorder</button></td></tr></tbody></table><div class="content-grid"><section class="panel"><div class="panel-head"><h2>AI inventory forecast</h2><span class="badge blue">FORECAST</span></div><p>Beard Oil Cedar may run out before the next wholesale delivery. Suggested order: 18 units.</p><button class="primary small" data-action="reorder">Create purchase order</button></section><section class="panel"><div class="panel-head"><h2>Retail performance</h2></div><b style="font-size:1.8rem">€1,842</b><p class="muted">Product revenue / 30 days · +14%</p></section></div>',
  ai: () =>
    '<div class="section-bar"><div><h2>AI Manager</h2><small class="muted">Barber-specific intelligence with owner control</small></div><div class="filters"><button class="active">Recommendations</button><button>Automations</button><button>Guardrails</button></div></div><div class="ai-grid"><article class="ai-action featured"><span class="tag">01 · EMPTY CHAIR RECOVERY</span><h3>Fill Demo Barber A's 15:30 slot</h3><p>Demo Waitlist Guest is a 96% match, available, and last visited 23 days ago.</p><span class="estimate">+€42</span><button data-action="fill-gap">Approve & send</button></article><article class="ai-action"><span class="tag">02 · HAIRCUT CYCLE</span><h3>14 customers are due today</h3><p>Personalized rebooking timed to each customer's actual haircut cycle.</p><span class="estimate">+€286</span><button data-action="campaign">Review messages</button></article><article class="ai-action"><span class="tag">03 · NO-SHOW RISK</span><h3>2 bookings need confirmation</h3><p>Explainable risk signal; pre-authorization is suggested for only one.</p><span class="estimate">€104 protected</span><button data-action="risk">Open risks</button></article><article class="ai-action"><span class="tag">04 · BARBER MATCH</span><h3>Better matching for new customers</h3><p>Based on style, hair type, portfolio, reviews and available capacity.</p><span class="estimate">98% top match</span><button data-action="match">View logic</button></article><article class="ai-action"><span class="tag">05 · CONTENT STUDIO</span><h3>8 before/after posts ready</h3><p>Customer consent checked and barber-brand tone applied.</p><span class="estimate">8 draft</span><button data-action="content">Open content</button></article><article class="ai-action"><span class="tag">06 · MARGIN COACH</span><h3>Cut + Beard price is low</h3><p>A €3–5 increase can be modeled from time and cost data.</p><span class="estimate">+€410 / month</span><button data-action="pricing">Run pricing model</button></article></div><div class="feature-matrix"><details open><summary>All 22 barber-specific AI capabilities</summary><p>Haircut Cycle Predictor · Empty Chair Recovery · No-show Risk Engine · Barber Match AI · Cut Memory · Visual Consultation · Walk-in Queue Optimiser · Smart Gap Compression · Demand & Capacity Forecast · AI Daily Brief · Client Churn Predictor · Personalised Reactivation · Revenue Attribution · AI Review Assistant · Before/After Content Studio · Price & Margin Coach · Smart Add-on Coach · Barber Performance Coach · Inventory Forecast · Conversational OS Command · AI Revenue Guardrails · Multilingual Concierge</p></details></div>',
  impact: () =>
    '<section class="impact-hero"><div><small>OPERATOR ATTRIBUTED VALUE · 30 DAYS</small><h2>' +
    money(state.impact) +
    " <span>estimated</span></h2></div></section>",
  settings: () =>
    '<div class="section-bar"><div><h2>Settings & integrations</h2><small class="muted">Core platform capabilities are represented in the demo</small></div><button class="primary small" data-action="save-settings">Save</button></div><div class="settings-grid"><article class="setting-card"><div class="toggle"></div><h3>Online booking</h3><p>White-label page, widget, direct link, QR, social and Reserve with Google.</p></article><article class="setting-card"><div class="toggle"></div><h3>Payments & protection</h3><p>Deposit, prepayment, card on file, pre-auth, cancellation fee, Tap to Pay.</p></article><article class="setting-card"><div class="toggle"></div><h3>Communication</h3><p>SMS, WhatsApp, email, push, two-way inbox and multilingual templates.</p></article><article class="setting-card"><div class="toggle"></div><h3>Services</h3><p>Variants, combos, add-ons, buffers, resources, custom pricing and barber levels.</p></article><article class="setting-card"><div class="toggle"></div><h3>Data & permissions</h3><p>GDPR, export, roles, audit log, consent and data retention.</p></article><article class="setting-card"><div class="toggle"></div><h3>Integrations</h3><p>Google Calendar, Meta, Google Business, accounting, API and webhooks.</p></article></div><div class="feature-matrix"><details open><summary>Booking & calendar</summary><p>24/7 booking · real-time availability · barber/first available · lead time · cancel/reschedule · drag-and-drop · break/time off · multiple locations · waitlist · combo/add-on/variant · buffer · resource · walk-in queue</p></details><details><summary>CRM & protection</summary><p>Profiles · history · notes · photos · forms · signatures · tags · VIP/blocking · wallet · inbox · reminder · deposit · prepayment · cancellation/no-show fee · risk-based pre-auth</p></details><details><summary>POS, marketing & operations</summary><p>POS · cash/card · Tap to Pay · terminal · tip · refund · receipt/VAT · gift card · package · membership · campaigns · segmentation · loyalty · reviews · analytics · staff · payroll/commission · inventory · multi-location</p></details></div>',
};
const coreGroups = {
  booking: {
    label: "Booking & Calendar",
    summary: "Full booking control without losing the AI-first workflow.",
    features: [
      [
        "Online + manual booking",
        "WORKING DEMO",
        "working",
        "manual-booking",
        "Create booking",
      ],
      [
        "Recurring appointments",
        "WORKING DEMO",
        "working",
        "core-recurring",
        state.recurringCreated ? "4 visits created" : "Create series",
      ],
      [
        "Group booking",
        "SIMULATED FEATURE",
        "simulated",
        "core-group",
        state.groupCreated ? "Party reserved" : "Reserve party",
      ],
      [
        "Resources / rooms / equipment",
        "SIMULATED FEATURE",
        "simulated",
        "core-resource",
        "Manage chairs",
      ],
      [
        "Forms & consultations",
        "WORKING DEMO",
        "working",
        "core-form",
        state.formSent ? "Consent captured" : "Send form",
      ],
      [
        "Waitlist, walk-ins & queue",
        "AI ENHANCED",
        "enhanced",
        "fill-live-slot",
        "Run predictive fill",
      ],
      [
        "Booking rules, buffers & availability",
        "WORKING DEMO",
        "working",
        "core-rules",
        "Edit rules",
      ],
      [
        "Multi-location booking",
        "WORKING DEMO",
        "working",
        "core-locations",
        "Open locations",
      ],
    ],
  },
  crm: {
    label: "CRM & Customer",
    summary: "Customer record, history and intelligence in one timeline.",
    features: [
      [
        "Profiles, visits, payments & communication",
        "WORKING DEMO",
        "working",
        "core-profile",
        "Open profile",
      ],
      [
        "Notes, photos, documents & forms",
        "WORKING DEMO",
        "working",
        "core-documents",
        "Open records",
      ],
      [
        "Tags, preferences & preferred employee",
        "WORKING DEMO",
        "working",
        "core-segments",
        "Manage segments",
      ],
      [
        "LTV, retention, churn & next visit",
        "AI ENHANCED",
        "enhanced",
        "reactivate",
        "Execute intervention",
      ],
      [
        "Saved cards & customer wallet",
        "SIMULATED FEATURE",
        "simulated",
        "core-wallet",
        "Open wallet",
      ],
      [
        "No-show history & policy state",
        "AI ENHANCED",
        "enhanced",
        "risk",
        "Review risk",
      ],
    ],
  },
  payments: {
    label: "POS & Payments",
    summary:
      "Checkout, protection and value programs remain manually controllable.",
    features: [
      [
        "Cash, card, Tap to Pay & receipts",
        "WORKING DEMO",
        "working",
        "open-checkout",
        "Open checkout",
      ],
      [
        "Deposits, prepayment & cancellation fees",
        "WORKING DEMO",
        "working",
        "core-deposit",
        "Edit protection",
      ],
      [
        "Tips & split payments",
        "SIMULATED FEATURE",
        "simulated",
        "core-split",
        "Run split payment",
      ],
      [
        "Refunds & adjustments",
        "WORKING DEMO",
        "working",
        "core-refund",
        state.refundPending ? "Approval pending" : "Request refund",
      ],
      [
        "Gift cards",
        "SIMULATED FEATURE",
        "simulated",
        "core-gift",
        "Balance " + money(state.giftBalance),
      ],
      [
        "Memberships",
        "SIMULATED FEATURE",
        "simulated",
        "core-membership",
        "Active · Monthly Cut",
      ],
      [
        "Packages",
        "SIMULATED FEATURE",
        "simulated",
        "core-package",
        state.packageCredits + " credits left",
      ],
      [
        "Cash management & payment reporting",
        "PLANNED PRODUCTION",
        "planned",
        "core-cash",
        "Open day close",
      ],
    ],
  },
  staff: {
    label: "Staff & Resources",
    summary: "Operational controls plus actionable capacity intelligence.",
    features: [
      [
        "Schedules, shifts, breaks & time off",
        "WORKING DEMO",
        "working",
        "core-shifts",
        "Open schedule",
      ],
      [
        "Roles & advanced permissions",
        "WORKING DEMO",
        "working",
        "core-permissions",
        "Edit access",
      ],
      [
        "Commission, tips & payout estimate",
        "SIMULATED FEATURE",
        "simulated",
        "core-payout",
        "Review payout",
      ],
      [
        "Services, prices & working hours",
        "WORKING DEMO",
        "working",
        "core-staff-services",
        "Edit staff setup",
      ],
      [
        "Revenue, utilization, retention & ticket",
        "AI ENHANCED",
        "enhanced",
        "staff-plan",
        "Create growth plan",
      ],
    ],
  },
  growth: {
    label: "Marketing & Growth",
    summary:
      "Owner sets the outcome; Operator chooses audience, channel and timing.",
    features: [
      [
        "Email, SMS & WhatsApp campaigns",
        "WORKING DEMO",
        "working",
        "campaign",
        "Prepare campaign",
      ],
      [
        "Rebooking, reactivation & win-back",
        "AI ENHANCED",
        "enhanced",
        "reactivate",
        "Execute plan",
      ],
      [
        "Birthday, reviews & Google reviews",
        "SIMULATED FEATURE",
        "simulated",
        "reviews",
        "Activate flow",
      ],
      [
        "Referrals & loyalty",
        "SIMULATED FEATURE",
        "simulated",
        "core-loyalty",
        state.loyaltyPoints + " points",
      ],
      [
        "Promotions, discounts & off-peak offers",
        "AI ENHANCED",
        "enhanced",
        "pricing",
        "Review guardrails",
      ],
      [
        "Campaign analytics & attribution",
        "WORKING DEMO",
        "working",
        "impact-detail",
        "Trace revenue",
      ],
      [
        "Marketplace, social & Google booking",
        "PLANNED PRODUCTION",
        "planned",
        "core-channels",
        "Manage channels",
      ],
    ],
  },
  inventory: {
    label: "Inventory & Retail",
    summary: "Stock control enhanced by booked-demand prediction.",
    features: [
      [
        "Products, stock & movements",
        "WORKING DEMO",
        "working",
        "core-stock",
        "Open stock ledger",
      ],
      [
        "Product sales & service consumption",
        "SIMULATED FEATURE",
        "simulated",
        "core-consumption",
        "Review usage",
      ],
      [
        "Low-stock warnings",
        "AI ENHANCED",
        "enhanced",
        "reorder",
        "Prepare replenishment",
      ],
      [
        "Suppliers & purchase orders",
        "WORKING DEMO",
        "working",
        "core-purchase",
        state.poPrepared ? "PO awaiting approval" : "Create PO",
      ],
      [
        "Inventory valuation & reporting",
        "PLANNED PRODUCTION",
        "planned",
        "core-valuation",
        "Open valuation",
      ],
      [
        "Online retail / click & collect",
        "PLANNED PRODUCTION",
        "planned",
        "core-retail",
        "View roadmap",
      ],
    ],
  },
  reports: {
    label: "Reporting & Analytics",
    summary: "Every report ends in an explanation or executable next action.",
    features: [
      [
        "Revenue, sales & payments",
        "WORKING DEMO",
        "working",
        "core-report",
        "Open report",
      ],
      [
        "Appointments, customers & no-shows",
        "WORKING DEMO",
        "working",
        "core-report",
        "Open report",
      ],
      [
        "Retention, churn & LTV",
        "AI ENHANCED",
        "enhanced",
        "core-report-plan",
        "Execute improvement plan",
      ],
      [
        "Utilization & staff performance",
        "AI ENHANCED",
        "enhanced",
        "staff-plan",
        "Create capacity plan",
      ],
      [
        "Marketing & inventory attribution",
        "WORKING DEMO",
        "working",
        "impact-detail",
        "Trace result",
      ],
      [
        "Locations & financial reporting",
        "SIMULATED FEATURE",
        "simulated",
        "diagnose-location",
        "Diagnose location",
      ],
      [
        "Data export & connector",
        "PLANNED PRODUCTION",
        "planned",
        "core-export",
        "View export plan",
      ],
    ],
  },
  platform: {
    label: "Platform & Admin",
    summary: "Complete replacement controls, integrations and migration.",
    features: [
      [
        "Multi-location, roles & security",
        "WORKING DEMO",
        "working",
        "core-admin",
        "Open admin",
      ],
      [
        "Responsive owner experience",
        "WORKING DEMO",
        "working",
        "core-mobile",
        "Preview mobile",
      ],
      [
        "Customer booking experience",
        "WORKING DEMO",
        "working",
        "core-guest",
        "Open guest view",
      ],
      [
        "Website, booking page & widget",
        "SIMULATED FEATURE",
        "simulated",
        "core-channels",
        "Manage channels",
      ],
      [
        "Notifications & social integrations",
        "SIMULATED FEATURE",
        "simulated",
        "core-channels",
        "Manage integrations",
      ],
      [
        "Data import / export",
        "PLANNED PRODUCTION",
        "planned",
        "core-import",
        "View migration",
      ],
      [
        "Marketplace / discovery",
        "PLANNED PRODUCTION",
        "planned",
        "core-marketplace",
        "View ecosystem",
      ],
    ],
  },
};
function coreCard(f) {
  return (
    '<article class="core-card"><header><em class="' +
    f[2] +
    '">' +
    f[1] +
    "</em></header><h3>" +
    f[0] +
    '</h3><button data-action="' +
    f[3] +
    '">' +
    f[4] +
    " →</button></article>"
  );
}
modules.core = () => {
  const setCoreLabel = (group, action, label) => {
    const feature = coreGroups[group].features.find((f) => f[3] === action);
    if (feature) feature[4] = label;
  };
  setCoreLabel(
    "booking",
    "core-recurring",
    state.recurringCreated ? "4 visits created" : "Create series",
  );
  setCoreLabel(
    "booking",
    "core-group",
    state.groupCreated ? "Party reserved" : "Reserve party",
  );
  setCoreLabel(
    "booking",
    "core-form",
    state.formSent ? "Consent captured" : "Send form",
  );
  setCoreLabel(
    "payments",
    "core-refund",
    state.refundPending ? "Approval pending" : "Request refund",
  );
  setCoreLabel(
    "payments",
    "core-package",
    state.packageCredits + " credits left",
  );
  setCoreLabel("growth", "core-loyalty", state.loyaltyPoints + " points");
  setCoreLabel(
    "inventory",
    "core-purchase",
    state.poPrepared ? "PO awaiting approval" : "Create PO",
  );
  let g = coreGroups[state.coreTab];
  return (
    '<section class="core-hero"><div><span>COMPLETE BUSINESS PLATFORM</span><h2>AI-first. Manual always available.</h2><p>The Operator prepares or performs routine work; every underlying control remains accessible here.</p></div><div><b>42</b><small>capabilities demonstrated</small></div></section><div class="core-tabs">' +
    Object.entries(coreGroups)
      .map(
        ([k, v]) =>
          '<button class="' +
          (k === state.coreTab ? "active" : "") +
          '" data-core-tab="' +
          k +
          '">' +
          v.label +
          "</button>",
      )
      .join("") +
    '</div><section class="core-section"><header><div><h2>' +
    g.label +
    "</h2><p>" +
    g.summary +
    '</p></div><span class="demo-chip">DEMO PRODUCT STATE</span></header><div class="core-grid">' +
    g.features.map(coreCard).join("") +
    '</div></section><div class="core-legend"><span><i class="working"></i> Working demo</span><span><i class="simulated"></i> Simulated feature</span><span><i class="planned"></i> Planned production</span><span><i class="enhanced"></i> AI enhanced</span><b>Covered means demonstrable — never an empty page.</b></div>'
  );
};
function statusLabel() {
  return state.plan === "active"
    ? '<span class="status-good">BACK ON TRACK</span>'
    : '<span class="status-risk">AT RISK</span>';
}
function planButton() {
  return state.plan === "active"
    ? '<button class="primary small" data-action="view-results">VIEW RESULTS</button>'
    : '<button class="primary small" data-action="approve-plan">REVIEW PLAN</button>';
}
modules.home = () =>
  '<div class="executive-top"><div><span class="eyebrow">MONTHLY REVENUE GOAL</span><h2>' +
  money(state.target) +
  "</h2>" +
  statusLabel() +
  '</div><div class="goal-track"><div><span>Current revenue</span><b>' +
  money(state.current) +
  "</b></div><div><span>Forecast revenue</span><b>" +
  money(state.forecast) +
  '</b></div><div><span>Projected gap</span><b class="' +
  (state.gap > 0 ? "negative" : "positive") +
  '">' +
  (state.gap > 0 ? "−" + money(state.gap) : "+" + money(Math.abs(state.gap))) +
  "</b></div><div><span>Business health</span><b>" +
  (state.plan === "active" ? "94" : "78") +
  ' / 100</b></div></div></div><section class="operator-alert"><div class="op-icon">✦</div><div><span>AI OPERATOR</span><h2>' +
  (state.plan === "active"
    ? "PLAN ACTIVE · " + money(1500) + " EXPECTED IMPACT"
    : "AI FOUND " + money(state.opportunity) + " IN OPPORTUNITIES") +
  "</h2><p>" +
  (state.plan === "active"
    ? "5 approved actions are executing within your rules."
    : "5 actions prepared. One owner decision required.") +
  "</p></div>" +
  planButton() +
  '</section><div class="grid-4"><article class="kpi"><span>UTILIZATION</span><b>' +
  (state.plan === "active" ? "79%" : "74%") +
  '</b><small>Target 82%</small></article><article class="kpi"><span>RETENTION</span><b>' +
  (state.plan === "active" ? "73%" : "71%") +
  '</b><small>Target 76%</small></article><article class="kpi"><span>TODAY APPOINTMENTS</span><b>' +
  (state.plan === "active" ? "22" : "17") +
  "</b><small>" +
  (state.plan === "active" ? "+5 by Operator" : "3 staff working") +
  '</small></article><article class="kpi"><span>EXPECTED REVENUE</span><b>' +
  (state.plan === "active" ? "€894" : "€684") +
  '</b><small>Today</small></article></div><div class="content-grid"><section class="panel"><div class="panel-head"><h2>Today at a glance</h2><button data-go="live">Open live business →</button></div><div class="metric-list"><div><span>Empty slots</span><b>' +
  (state.plan === "active" ? "3" : "8") +
  "</b></div><div><span>Cancellations</span><b>2</b></div><div><span>Staff working</span><b>3</b></div><div><span>Decisions required</span><b>" +
  (state.plan === "active" ? "0" : "1") +
  '</b></div></div></section><section class="panel notification-card"><span>DECISION PHILOSOPHY</span><h3>Less administration.<br>Fewer decisions.<br>Better outcomes.</h3><p>Normal operations stay quiet. You are notified only when policy, money or strategy requires your judgment.</p></section></div><div class="home-footer"><button class="ghost" data-action="reset-demo">↻ Reset full demo story</button><span>All numbers marked as demo data are simulated.</span></div>';
modules.operator = () => {
  const active = state.plan === "active";
  return '<section class="operator-command"><div class="operator-command-copy"><span class="eyebrow">✦ AI BUSINESS OPERATOR · DEMO</span><h2>' +
    (active ? 'Your growth plan is running.' : 'I found 6 opportunities to close the revenue gap.') +
    '</h2><p>' + (active ? 'Approved actions are executing inside your rules. Outcomes are measured and written back to Business Memory.' : 'I analyzed capacity, return cycles, churn risk and margin. One owner decision unlocks the plan.') +
    '</p></div><div class="operator-goal-ring"><small>MONTHLY GOAL</small><b>'+money(state.target)+'</b><span>'+money(state.forecast)+' forecast</span></div></section>' +
    '<div class="operator-command-metrics"><div><small>CURRENT</small><b>'+money(state.current)+'</b></div><div><small>FORECAST</small><b>'+money(state.forecast)+'</b></div><div><small>GAP</small><b class="'+(state.gap>0?'negative':'positive')+'">'+(state.gap>0?'−'+money(state.gap):'+'+money(Math.abs(state.gap)))+'</b></div><div><small>MODE</small><b>COPILOT</b></div></div>' +
    '<section class="operator-priority"><div class="priority-head"><div><span>HIGHEST-IMPACT OPPORTUNITY</span><h3>Recover demand already inside the business</h3></div><span class="demo-chip">SIMULATED</span></div><div class="priority-body"><div class="priority-number"><small>EXPECTED IMPACT</small><b>+€540</b><span>12 high-value customers</span></div><div class="priority-why"><span>WHY NOW</span><p>47 customerss are due to return and Tuesday–Thursday utilization is only 61%. Business Memory favors personalized rebooking over broad discounting.</p></div><div class="priority-confidence"><span>CONFIDENCE</span><b>82%</b><small>Low risk · €18 estimated cost</small></div></div></section>' +
    '<section class="operator-opportunities"><div class="panel-head"><div><span class="eyebrow">OPPORTUNITY QUEUE</span><h2>6 opportunities ranked by expected business impact</h2></div><button class="text-btn" data-action="reasoning">How I ranked these →</button></div>' +
    '<div class="opportunity-queue">' +
    '<article class="op-row featured"><span class="op-rank">01</span><div><b>Reactivate high-value customers</b><small>12 customers · cycle-aware outreach · no broad discount</small></div><span class="op-signal">82% confidence</span><strong>+€540</strong></article>' +
    '<article class="op-row"><span class="op-rank">02</span><div><b>Personalized rebooking</b><small>47 customerss due to return · preferred barber/time considered</small></div><span class="op-signal">79% confidence</span><strong>+€390</strong></article>' +
    '<article class="op-row"><span class="op-rank">03</span><div><b>Recover cancellations with smart waitlist</b><small>8 best-fit offers · no discount required</small></div><span class="op-signal">88% confidence</span><strong>+€280</strong></article>' +
    '<article class="op-row"><span class="op-rank">04</span><div><b>Contextual service & product upsell</b><small>Only where purchase history indicates relevance</small></div><span class="op-signal">71% confidence</span><strong>+€170</strong></article>' +
    '<article class="op-row"><span class="op-rank">05</span><div><b>Shift underperforming campaign budget</b><small>Move €47 toward the higher-converting segment</small></div><span class="op-signal">76% confidence</span><strong>+€120</strong></article>' +
    '<article class="op-row quiet"><span class="op-rank">06</span><div><b>Protect two higher-risk bookings</b><small>Confirmation / pre-auth within existing policy</small></div><span class="op-signal">Risk reduction</span><strong>Protect</strong></article></div></section>' +
    '<section class="operator-plan-dock"><div><small>PREPARED PLAN · 5 REVENUE ACTIONS</small><b>+€1,500 expected impact</b><span>€47 estimated cost · 78% plan confidence · Low risk</span></div><div class="plan-actions">' +
    (active ? '<button class="primary" data-action="view-results">VIEW MEASURED IMPACT</button><button class="secondary" data-go="decisions">DECISION LOG</button>' : '<button class="primary" data-action="approve-plan">APPROVE & EXECUTE</button><button class="secondary" data-action="modify-plan">MODIFY</button><button class="secondary" data-action="reject-plan">REJECT</button><button class="text-btn" data-action="reasoning">SHOW REASONING</button>') +
    '</div></section>' +
    '<section class="operator-loop"><span><i>1</i><b>OBSERVE</b><small>Bookings · customers · staff</small></span><em>→</em><span><i>2</i><b>DETECT</b><small>Risks & opportunities</small></span><em>→</em><span><i>3</i><b>PLAN</b><small>Rank expected impact</small></span><em>→</em><span><i>4</i><b>ACT</b><small>Within permissions</small></span><em>→</em><span><i>5</i><b>MEASURE</b><small>Attribute outcomes</small></span><em>→</em><span><i>6</i><b>LEARN</b><small>Update Business Memory</small></span></section>';
};
modules.live = () =>
  '<div class="live-strip"><div><span>LIVE BUSINESS</span><b>3 staff · ' +
  (state.plan === "active" ? "22" : "17") +
  ' appointments</b></div><span class="live-now"><i></i> Updated now</span></div><div class="staff-live"><article><header><span class="avatar lime">SA</span><div><b>Demo Barber D</b><small>BUSY · ends 14:45</small></div></header><div class="seat-progress"><i style="width:82%"></i></div><p>Utilization 92% · next 15:00</p></article><article><header><span class="avatar dark">MK</span><div><b>Demo Barber B</b><small>AVAILABLE · next 15:30</small></div></header><div class="seat-progress"><i style="width:61%"></i></div><p>Capacity for +€2,100 / month</p></article><article class="' +
  (state.liveSlotFilled ? "" : "attention") +
  '"><header><span class="avatar sand">DS</span><div><b>Demo Barber A</b><small>' +
  (state.liveSlotFilled
    ? "BOOKED · Demo Customer M at 14:30"
    : "CANCELLATION · 14:30 available") +
  '</small></div></header><div class="seat-progress"><i style="width:' +
  (state.liveSlotFilled ? "79" : "58") +
  '%"></i></div><p>' +
  (state.liveSlotFilled
    ? "€45 recovered · recorded in Impact"
    : "8 matching customers found") +
  "</p></article></div>" +
  (state.liveSlotFilled
    ? '<section class="resolved-card"><span>✓ SLOT FILLED</span><h2>Anna accepted the 14:30 appointment.</h2><p>Calendar, customer history, forecast, Impact, Decision Log and Business Memory were updated.</p><button class="primary" data-go="decisions">View decision trail</button></section>'
    : '<section class="decision-required"><div><span>DECISION REQUIRED</span><h2>€45 revenue opportunity detected.</h2><p>8 matching customers found. Waitlist offers are allowed automatically by your policy.</p></div><div><small>POTENTIAL REVENUE</small><b>€45</b><button class="primary" data-action="fill-live-slot">FILL SLOT</button></div></section>');
modules.goals = () =>
  '<div class="goals-intro"><div><span>OWNER RESPONSIBILITY</span><h2>Set outcomes. The Operator handles the work.</h2><p>Every recommendation and autonomous action is evaluated against these goals and your rules.</p></div><span class="demo-chip">DEMO DATA</span></div><div class="goal-list">' +
  [
    [
      "Monthly revenue",
      "€25,000",
      "€" + (state.forecast / 1000).toFixed(1) + "k",
      state.plan === "active" ? "100%" : "95%",
    ],
    [
      "Utilization",
      "82%",
      state.plan === "active" ? "79%" : "74%",
      state.plan === "active" ? "96%" : "90%",
    ],
    ["Retention", "76%", state.plan === "active" ? "73%" : "71%", "93%"],
    ["Average ticket", "€49", "€46", "94%"],
    ["Customer rating", "4.9", "4.9", "100%"],
    ["Profit margin", "24%", "22.8%", "95%"],
  ]
    .map(
      (g) =>
        "<article><div><span>" +
        g[0] +
        "</span><b>" +
        g[1] +
        '</b></div><div class="goal-bar"><i style="width:' +
        g[3] +
        '"></i></div><div><small>CURRENT / FORECAST</small><b>' +
        g[2] +
        '</b></div><button data-action="goal-improve">LET AI IMPROVE</button></article>',
    )
    .join("") +
  '</div><section class="budget-card"><div><span>MARKETING BUDGET</span><b>€600 / month</b></div><p>€384 used · Operator may automatically spend up to €100 / week.</p><button class="ghost" data-go="autopilot">Edit rule</button></section>';
modules.autopilot = () =>
  '<div class="mode-select"><button><span>ASSIST</span><small>AI identifies and suggests only.</small></button><button class="active"><span>COPILOT</span><small>AI prepares; owner approves material decisions.</small></button><button><span>AUTOPILOT</span><small>AI executes within owner-defined rules.</small></button></div><section class="permission-panel"><div class="panel-head"><div><h2>Execution permissions</h2><small>The owner can change every rule. Price changes are never automatic.</small></div><span class="demo-chip">DEFAULT · COPILOT</span></div><div class="permission-list">' +
  permissionRow("marketing", "Marketing spend", "≤ €100 / week", "Automatic") +
  permissionRow("discount", "Discount", "≤ 10%", "Automatic") +
  permissionRow("waitlist", "Waitlist offers", "No spend", "Automatic") +
  permissionRow("rebooking", "Rebooking", "Existing customers", "Automatic") +
  permissionRow(
    "reviews",
    "Review requests",
    "After completed visit",
    "Automatic",
  ) +
  permissionRow(
    "reactivation",
    "Customer reactivation",
    "No discount",
    "Automatic",
  ) +
  permissionRow("inventory", "Inventory purchase", "> €50", "Approval") +
  permissionRow("refund", "Refund", "Any amount", "Approval") +
  permissionRow("schedule", "Staff schedule change", "Any change", "Approval") +
  permissionRow("price", "Price change", "Any change", "Never automatic") +
  '</div></section><section class="notification-rule"><div><span>NOTIFICATION RULE</span><h3>Notify me only when a decision is required.</h3><p>Routine executions are summarized in the Decision Log and daily brief.</p></div><div class="toggle on"></div></section>';
function permissionRow(k, n, l, m) {
  return (
    '<div class="permission-row"><div><b>' +
    n +
    "</b><small>" +
    l +
    '</small></div><select data-permission="' +
    k +
    '"><option ' +
    (state.permissions[k] ? "selected" : "") +
    ">Automatic</option><option " +
    (!state.permissions[k] ? "selected" : "") +
    '>Approval</option><option>Never</option></select><span class="policy-state ' +
    (state.permissions[k] ? "auto" : "approval") +
    '">' +
    m +
    "</span></div>"
  );
}
modules.memory = () =>
  '<div class="memory-hero"><span>BUSINESS MEMORY</span><h2>The Operator improves strategy from outcomes, not assumptions.</h2><p>Only observed business results are promoted into memory.</p></div><div class="memory-grid"><article><span>REBOOKING</span><h3>Personalized rebooking performs 2.3× better than discounts.</h3><small>Based on 184 completed outreach actions</small></article><article><span>CAPACITY</span><h3>Thursday 13:00–16:00 consistently underperforms.</h3><small>Observed across 14 weeks</small></article><article><span>CUSTOMER CYCLE</span><h3>Demo Barber B’s customers return every 26.4 days on average.</h3><small>Confidence 91%</small></article><article><span>MARGIN</span><h3>Saturday discounts reduce margin without meaningful growth.</h3><small>Strategy guardrail updated</small></article><article><span>REVIEWS</span><h3>Review requests within two hours perform 34% better.</h3><small>Based on 312 completed visits</small></article>' +
  (state.plan === "active"
    ? '<article class="new-memory"><span>NEW · PLAN RESULT</span><h3>Cycle-aware reactivation closed the revenue gap without increasing discounts.</h3><small>Recorded from approved plan · today</small></article>'
    : "") +
  '</div><section class="strategy-change"><div><span>AI STRATEGY CHANGE</span><h2>Stop using broad discounts for slow periods.</h2></div><div class="strategy-flow"><div><small>OLD STRATEGY</small><b>15% Tuesday discount</b></div><div><small>WHAT HAPPENED</small><b>Bookings +4%, margin −11%</b></div><div><small>LEARNING</small><b>Timing beats discounting</b></div><div><small>NEXT STRATEGY</small><b>Cycle-aware rebooking first</b></div></div></section>';
modules.simulator = () =>
  '<section class="simulator-head"><span>ASK YOUR BUSINESS</span><h2>Test a decision before you make it.</h2><p>Predictive outputs below are clearly labeled simulated and are not financial guarantees.</p><span class="demo-chip">DEMO / SIMULATED DATA</span></section><div class="question-chips"><button data-sim="price">What happens if I increase haircut prices by €5?</button><button data-sim="hire">What happens if I hire another employee?</button><button data-sim="sunday">Should we open Sundays?</button><button data-sim="marketing">What if I spend €500 more on marketing?</button><button data-sim="discount">What if we stop discounts?</button></div><div id="simulationResult">' +
  simulation("price") +
  "</div>";
function simulation(k) {
  let data = {
    price: [
      "Increase haircut prices by €5",
      "+€1,840",
      "+€1,310",
      "−3.2%",
      "Medium",
      "82%",
      "Increase €3 for new customers first",
    ],
    hire: [
      "Hire another employee",
      "+€4,200",
      "+€1,460",
      "+18% capacity",
      "Medium",
      "74%",
      "Add two peak-day contractors first",
    ],
    sunday: [
      "Open Sundays",
      "+€1,060",
      "−€240",
      "Low organic demand",
      "High",
      "68%",
      "Pilot two Sundays per month",
    ],
    marketing: [
      "Add €500 marketing",
      "+€1,280",
      "+€430",
      "+37 leads",
      "Medium",
      "72%",
      "Spend €220 on reactivation instead",
    ],
    discount: [
      "Stop discounts",
      "−€320",
      "+€610",
      "−5 bookings",
      "Low",
      "86%",
      "Replace with personalized rebooking",
    ],
  }[k];
  return (
    '<section class="simulation-card"><header><div><small>SCENARIO</small><h3>' +
    data[0] +
    '</h3></div><span class="demo-chip">SIMULATED</span></header><div class="scenario-grid"><div><small>CURRENT SCENARIO</small><b>€23,680 forecast</b></div><div><small>PREDICTED REVENUE</small><b>' +
    data[1] +
    "</b></div><div><small>PROFIT IMPACT</small><b>" +
    data[2] +
    "</b></div><div><small>DEMAND IMPACT</small><b>" +
    data[3] +
    "</b></div><div><small>RISK</small><b>" +
    data[4] +
    "</b></div><div><small>CONFIDENCE</small><b>" +
    data[5] +
    '</b></div></div><div class="alternative"><small>LOWER-RISK ALTERNATIVE</small><b>' +
    data[6] +
    "</b></div></section>"
  );
}
modules.locations = () =>
  '<div class="location-grid"><article><div><span>VIENNA CENTER</span><b>Health 94</b></div><h3>€25,180</h3><p>Forecast revenue · 82% utilization</p><span class="badge">ON TRACK</span></article><article class="location-risk"><div><span>VIENNA WEST</span><b>Health 78</b></div><h3>€18,420</h3><p>Forecast revenue · 61% utilization</p><span class="badge red">ATTENTION</span></article><article><div><span>VIENNA NORTH</span><b>Health 87</b></div><h3>€21,740</h3><p>Forecast revenue · 76% utilization</p><span class="badge blue">STABLE</span></article></div><section class="decision-required"><div><span>OPERATOR DIAGNOSIS</span><h2>Vienna West requires attention.</h2><p>Tue–Thu capacity is underused; rebooking is 14 points below network average.</p></div><div><small>RECOVERABLE / MONTH</small><b>€2,140</b><button class="primary" data-action="diagnose-location">DIAGNOSE</button></div></section>';
modules.decisions = () =>
  '<div class="section-bar"><div><h2>Decision Log</h2><small class="muted">Complete audit trail · newest first</small></div><span class="demo-chip">DEMO DATA</span></div><div class="decision-log">' +
  (state.recurringCreated
    ? decisionEntry(
        "Today · 14:18",
        "Manual recurring booking requested",
        "4 cycle-aware visits reserved",
        "€0",
        "Forecast +€168",
        "Manual control uses the same shared state",
      )
    : "") +
  (state.manualBooking
    ? decisionEntry(
        "Today · 14:12",
        "Owner created an appointment",
        "Demo Customer N booked with Demo Barber B",
        "€0",
        "Forecast +€42",
        "Manual actions remain fully auditable",
      )
    : "") +
  (state.liveSlotFilled
    ? decisionEntry(
        "Today · 14:03",
        "Cancellation detected",
        "8 matching customers found → waitlist contacted",
        "€0",
        "Demo Customer M booked · €45 recovered",
        "Result added to Business Memory",
      )
    : "") +
  (state.plan === "active"
    ? decisionEntry(
        "Today · 13:48",
        "Revenue goal projected to miss by €1,320",
        "5-action plan approved by owner",
        "€47",
        "Forecast increased to €25,180",
        "Cycle-aware rebooking outperformed discounts",
      )
    : "") +
  decisionEntry(
    "Yesterday · 18:12",
    "Completed visit with 5★ signal",
    "Review request sent within 2 hours",
    "€0.06",
    "Review received",
    "Fast review timing performs 34% better",
  ) +
  decisionEntry(
    "Sep 20 · 09:15",
    "High no-show risk on peak slot",
    "Card pre-authorization requested",
    "€0",
    "Booking confirmed · €52 protected",
    "Pre-auth effective for explained high-risk cases",
  ) +
  "</div>";
function decisionEntry(w, y, a, c, r, l) {
  return (
    '<article><div class="decision-when">' +
    w +
    "</div><div><small>WHY</small><b>" +
    y +
    "</b></div><div><small>WHAT</small><b>" +
    a +
    "</b></div><div><small>COST</small><b>" +
    c +
    "</b></div><div><small>RESULT</small><b>" +
    r +
    "</b></div><div><small>LEARNING</small><b>" +
    l +
    "</b></div></article>"
  );
}
modules.customers = () =>
  '<div class="section-bar"><div><h2>Customer Intelligence</h2><small class="muted">1,284 profiles · decisions, not database administration</small></div><span class="demo-chip">DEMO DATA</span></div><div class="customer-layout"><section class="customer-list"><div class="list-search"><input placeholder="Search customer…"></div><div class="client-row active"><span class="avatar dark">LM</span><div><b>Demo Customer</b><small>VIP · LTV €1,840</small></div></div><div class="client-row"><span class="avatar lime">MF</span><div><b>Demo Customer B</b><small>' +
  (state.plan === "active"
    ? "REACTIVATED · booked"
    : "LIKELY OVERDUE · 71% AI chance") +
  '</small></div></div><div class="client-row"><span class="avatar sand">PN</span><div><b>Demo Customer C</b><small>Churn risk · high value</small></div></div></section><section class="customer-profile"><div class="profile-top"><div class="profile-name"><span class="avatar dark">LM</span><div><h2>Demo Customer</h2><p>VIP · preferred employee: Demo Barber A · preferred time: 16:00–18:00</p></div></div><div class="profile-actions"><button class="primary small" data-action="reactivate">REACTIVATE</button></div></div><div class="profile-body"><div class="profile-stats"><div class="mini-stat"><span>LIFETIME VALUE</span><b>€1,840</b></div><div class="mini-stat"><span>VISITS</span><b>28</b></div><div class="mini-stat"><span>AVERAGE SPEND</span><b>€65.70</b></div><div class="mini-stat"><span>TYPICAL CYCLE</span><b>25 days</b></div><div class="mini-stat"><span>LAST VISIT</span><b>28 Aug</b></div><div class="mini-stat"><span>NO-SHOWS</span><b>0</b></div><div class="mini-stat"><span>LOYALTY</span><b>840 pts</b></div><div class="mini-stat"><span>MEMBERSHIP</span><b>NOIR Plus</b></div></div><section class="customer-ai"><span>✦ AI STATUS · LIKELY OVERDUE</span><div><p>Return probability without action</p><b>34%</b></div><div><p>Personalized rebooking probability</p><b>71%</b></div><p>Predicted next visit: September 24–29 · recommended channel: WhatsApp · no discount.</p></section><div class="customer-tabs"><span>Booking history</span><span>Payment history</span><span>Notes & preferences</span><span>Photos</span><span>Communication</span></div><section class="cut-memory"><div class="cut-head"><div><span>CUT MEMORY</span><h3>0 → 1.5 low–mid fade · 5 cm textured top</h3></div><span>Updated Aug 28</span></div></section></div></section></div>';
modules.staff = () =>
  '<div class="section-bar"><div><h2>Staff Intelligence</h2><small class="muted">Capacity and economics · no vanity ranking</small></div><span class="demo-chip">DEMO DATA</span></div><div class="staff-cards"><article><header><span class="avatar lime">SA</span><div><h3>Demo Barber D</h3><p>Senior barber</p></div></header><div class="staff-metrics"><span>Revenue <b>€8,420</b></span><span>Utilization <b>94%</b></span><span>Retention <b>82%</b></span><span>Avg. ticket <b>€58</b></span><span>Hours <b>168</b></span><span>Payout est. <b>€3,940</b></span></div><div class="staff-insight"><b>✦ Capacity insight</b><p>Demo Barber D is approaching capacity. Additional marketing is unlikely to produce meaningful growth.</p><button data-action="staff-plan">CREATE GROWTH PLAN</button></div></article><article><header><span class="avatar dark">MK</span><div><h3>Demo Barber B</h3><p>Barber & stylist</p></div></header><div class="staff-metrics"><span>Revenue <b>€5,260</b></span><span>Utilization <b>68%</b></span><span>Retention <b>74%</b></span><span>Avg. ticket <b>€49</b></span><span>Hours <b>160</b></span><span>Payout est. <b>€2,710</b></span></div><div class="staff-insight opportunity-insight"><b>✦ Growth capacity</b><p>Demo Barber B has capacity for approximately €2,100 additional monthly revenue.</p><button data-action="staff-plan">CREATE GROWTH PLAN</button></div></article></div><section class="core-links"><span>Schedule</span><span>Roles & permissions</span><span>Commission</span><span>Tips</span><span>Holidays</span><span>Working hours</span><span>Services</span><span>Customers</span></section>';
modules.calendar = () =>
  '<div class="section-bar"><div><h2>Calendar · September 22</h2><small class="muted">3 staff · ' +
  (state.plan === "active" ? "79%" : "74%") +
  " utilization · " +
  (state.plan === "active" ? "5 Operator bookings added" : "8 empty slots") +
  '</small></div><div class="filters"><button class="active">Day</button><button>Week</button><button>Locations</button><button data-action="manual-booking">+ Manual booking</button></div></div>' +
  (state.manualBooking
    ? '<section class="state-change-banner"><b>Manual booking added · Demo Customer N · Classic Cut · 18:00</b><span>+€42 forecast · shared demo state</span></section>'
    : "") +
  (state.recurringCreated
    ? '<section class="state-change-banner"><b>Recurring series created · Demo Risk Guest A · 4 visits</b><span>+€168 forecast · next 4 cycles reserved</span></section>'
    : "") +
  (state.plan === "active"
    ? '<section class="state-change-banner"><b>✓ OPERATOR PLAN APPLIED</b><span>5 new bookings added · forecast +€1,500 · traceable in Impact</span></section>'
    : "") +
  '<div class="calendar-board">' +
  calendar() +
  "</div>" +
  (state.plan === "active"
    ? '<section class="new-bookings"><h3>New bookings from approved plan</h3><div><span>Demo Customer B · Rebooking</span><b>Wed 17:00 · €42</b></div><div><span>Demo Customer C · Reactivation</span><b>Thu 15:30 · €52</b></div><div><span>Demo Customer M · Waitlist recovery</span><b>Today 14:30 · €45</b></div></section>'
    : "");
modules.impact = () =>
  '<section class="impact-hero"><div><span class="demo-chip">DEMO DATA · ATTRIBUTED</span><h2>' +
  money(state.impact) +
  ' <span>estimated business impact</span></h2><p>Every amount links to an AI action, customer and booking.</p></div><div class="roi">' +
  Math.round(state.impact / 79) +
  '×<small> impact / €79 subscription</small></div></section><div class="impact-grid"><article><small>REVENUE GENERATED</small><b>' +
  money(state.plan === "active" ? 3610 : 2410) +
  "</b><span>from completed / expected bookings</span></article><article><small>REVENUE RECOVERED</small><b>" +
  money(state.plan === "active" ? 870 : 570) +
  "</b><span>cancellations and churn</span></article><article><small>COSTS AVOIDED</small><b>€340</b><span>no-shows and inefficient spend</span></article><article><small>AI ACTIONS EXECUTED</small><b>" +
  (state.plan === "active" ? "127" : "122") +
  "</b><span>view audit trail</span></article><article><small>CUSTOMERS RECOVERED</small><b>" +
  (state.plan === "active" ? "31" : "19") +
  "</b><span>reactivated and booked</span></article><article><small>EMPTY APPOINTMENTS FILLED</small><b>" +
  (state.plan === "active" ? "17" : "12") +
  "</b><span>waitlist and direct offers</span></article><article><small>OWNER TIME SAVED</small><b>" +
  (state.plan === "active" ? "19.4" : "13.8") +
  ' h</b><span>estimated from automated work</span></article></div><section class="attribution-table"><div class="panel-head"><h2>Attribution trail</h2><span class="demo-chip">CLICKABLE DEMO DATA</span></div><div data-action="impact-detail"><span>Cycle-aware reactivation plan</span><b>12 customers</b><strong>+€540</strong><em>View →</em></div><div data-action="impact-detail"><span>Cancellation / waitlist recovery</span><b>8 offers · 3 bookings</b><strong>+€280</strong><em>View →</em></div><div data-action="impact-detail"><span>Personalized rebooking</span><b>47 messages · 9 bookings</b><strong>+€390</strong><em>View →</em></div><div data-action="impact-detail"><span>No-show protection</span><b>5 protected bookings</b><strong>+€238</strong><em>View →</em></div></section>';
function renderModule(id) {
  state.module = id;
  saveDemoState();
  let t = titles[id];
  $("#pageTitle").textContent = t[0];
  $("#pageSub").textContent = t[1];
  $("#moduleContent").innerHTML = modules[id]();\n  if (!ownerDemoMode && ownerDashboardData && ["home","calendar","customers"].includes(id)) { $("#moduleContent").insertAdjacentHTML("afterbegin",liveMetricsPanel()+liveOwnerPanel()+(id==="customers"||id==="home"?liveCrmPanel():"")); bindLiveCrm(); }\n  if (!ownerDemoMode && ownerAccessToken && id==="operator") { loadLiveOperator().then(()=>{ if(state.module==="operator" && liveOperatorSnapshot) $("#moduleContent").insertAdjacentHTML("afterbegin",liveOperatorBanner()); }); }\n  if (!ownerDemoMode && ownerAccessToken && ["impact","decisions"].includes(id)) { loadLiveOperator().then(()=>{ if(["impact","decisions"].includes(state.module) && liveOperatorSnapshot) $("#moduleContent").insertAdjacentHTML("afterbegin",liveOperatorBanner()); }); }
  if (state.guestBooking && ["calendar","customers","money","impact","decisions"].includes(id)) {
    const b = state.guestBooking;
    const synced = document.createElement("section");
    synced.className = "synced-booking";
    synced.innerHTML =
      '<div><span>SYNCED GUEST BOOKING · WORKING DEMO</span><h3>' +
      (id === "money" ? "€10 simulated deposit recorded" :
       id === "impact" ? "Direct booking · excluded from AI attribution" :
       id === "customers" ? "Demo Guest profile updated" :
       id === "decisions" ? "Guest lifecycle audit trail" :
       "Guest booking added to calendar") +
      '</h3><p>' + b.service + ' · ' + b.barber + ' · ' + b.time +
      ' · Total €' + b.price + ' · Deposit €' + (b.deposit || 0) + ' · Remaining €' + b.remaining +
      '</p></div><b>' + (b.status === "Cancelled" ? "CANCELLED" : "CONFIRMED") + '</b>';
    $("#moduleContent").prepend(synced);
    if(state.futureBooking && ["calendar","customers"].includes(id)){
      const f=document.createElement("section"); f.className="synced-booking";
      f.innerHTML='<div><span>FUTURE REBOOK · WORKING DEMO</span><h3>Next visit reserved</h3><p>'+state.futureBooking.service+' · '+state.futureBooking.barber+' · '+state.futureBooking.time+' · €'+state.futureBooking.price+'</p></div><b>CONFIRMED</b>';
      $("#moduleContent").prepend(f);
    }
    if(id==="decisions" && state.guestEvents.length){
      const trail=document.createElement("section"); trail.className="guest-audit-trail";
      trail.innerHTML='<div class="panel-head"><h2>Guest booking events</h2><span class="demo-chip">WORKING DEMO</span></div>'+
        state.guestEvents.map(x=>'<div class="guest-event"><b>'+x.type+'</b><span>'+x.detail+'</span><strong>'+x.result+'</strong></div>').join("");
      $("#moduleContent").prepend(trail);
    }
  }
  $$("[data-module]").forEach((b) =>
    b.classList.toggle("active", b.dataset.module === id),
  );
  bind();
  window.scrollTo({ top: 0, behavior: "smooth" });
}
window.renderModule = renderModule;
window.act = act;
window.openDrawer = openDrawer;
window.closeDrawer = closeDrawer;

// One delegated controller for dynamic Owner OS controls. It survives every innerHTML rerender.
document.addEventListener("click", (e) => {
  const go = e.target.closest("[data-go]");
  if (go) { e.preventDefault(); return renderModule(go.dataset.go); }

  const action = e.target.closest("[data-action]");\n  if(action?.dataset.action==="new-appointment" && !ownerDemoMode && ownerDashboardData){e.preventDefault();ownerBookingModal("create");return;}
  if (action && !action.matches('[data-action="repeat-cut"],[data-action="waitlist"],[data-action="new-booking"]')) {
    e.preventDefault();
    return act(action.dataset.action, action);
  }

  const coreTab = e.target.closest("[data-core-tab]");
  if (coreTab) { e.preventDefault(); state.coreTab = coreTab.dataset.coreTab; return renderModule("core"); }

  const sim = e.target.closest("[data-sim]");
  if (sim) {
    e.preventDefault();
    const out = $("#simulationResult");
    if (out) out.innerHTML = simulation(sim.dataset.sim);
    $$("[data-sim]").forEach(x => x.classList.toggle("active", x === sim));
  }
});

function bind() {
  $$("[data-permission]").forEach(
    (s) =>
      (s.onchange = () => {
        state.permissions[s.dataset.permission] = s.value === "Automatic";
        toast(
          "Policy updated",
          s.closest(".permission-row").querySelector("b").textContent +
            " · " +
            s.value,
        );
      }),
  );
  $$(".mode-select button").forEach(
    (b) =>
      (b.onclick = () => {
        $$(".mode-select button").forEach((x) => x.classList.remove("active"));
        b.classList.add("active");
        toast("Operating mode changed", b.querySelector("span").textContent);
      }),
  );
  $$("[data-tip]").forEach(
    (b) =>
      (b.onclick = () => {
        $$("[data-tip]").forEach((x) => x.classList.remove("active"));
        b.classList.add("active");
        state.tip = +b.dataset.tip;
        checkout();
      }),
  );
  $$(".payment-methods button").forEach(
    (b) =>
      (b.onclick = () => {
        $$(".payment-methods button").forEach((x) =>
          x.classList.remove("active"),
        );
        b.classList.add("active");
      }),
  );
}
function openDrawer(h) {
  $("#drawerContent").innerHTML = h;
  $("#drawer").classList.remove("hidden");
  $("#overlay").classList.remove("hidden");
  $$("[data-action]", $("#drawer")).forEach(
    (b) => (b.onclick = () => act(b.dataset.action, b)),
  );
}
function closeDrawer() {
  $("#drawer").classList.add("hidden");
  $("#overlay").classList.add("hidden");
}
function appointment() {
  openDrawer(
    '<span class="drawer-kicker">BOOKING · TODAY 16:15</span><h2>Demo Customer</h2><p class="muted">Skin Fade + Beard · Demo Barber A · 60 min</p><div class="drawer-section"><div class="detail-grid"><div><small>STATUS</small><b>✓ Confirmed</b></div><div><small>PAYMENT</small><b>€52 on site</b></div><div><small>RISK</small><b>Low · 4%</b></div><div><small>CYCLE</small><b>Day 25 · on schedule</b></div></div></div><div class="drawer-section"><h3>✦ Cut Memory</h3><p>0 → 1.5 low–mid fade · 5 cm textured top · 6 mm beard · Matte Clay · keep natural crown.</p></div><div class="drawer-section"><h3>Customer history</h3><p>12 visits · €624 spend · 0 no-shows · 4.9 ★ average review</p></div><div class="drawer-actions"><button class="confirm" data-action="open-checkout">Open checkout</button><button data-action="message-client">Message</button><button data-action="reschedule">Reschedule</button><button class="danger" data-action="cancel-booking">Cancel</button></div>',
  );
}
let liveOperatorSnapshot=null;
async function loadLiveOperator(){
 if(ownerDemoMode||!ownerAccessToken)return null;
 try{liveOperatorSnapshot=await ownerRpc("owner_operator_snapshot",{});return liveOperatorSnapshot}catch(e){console.error("Operator snapshot",e);return null}
}
function liveOperatorBanner(){
 if(ownerDemoMode||!liveOperatorSnapshot)return "";
 const s=liveOperatorSnapshot.signals||{},d=(liveOperatorSnapshot.decisions||[])[0];
 return '<section class="synced-booking"><div><span>AI OPERATOR · LIVE BUSINESS SIGNALS</span><h3>'+s.cancelled_future+' cancelled future slots · '+s.upcoming_7d+' upcoming bookings</h3><p>Booked revenue in current month: €'+((s.booked_revenue_cents||0)/100).toFixed(0)+' · '+s.customers+' customers</p></div><b>LIVE</b></section>'+
 (d?'<section class="guest-audit-trail"><div class="panel-head"><h2>Latest live decision</h2><span class="demo-chip">'+String(d.status).toUpperCase()+'</span></div><div class="guest-event"><b>'+d.kind+'</b><span>'+d.reason+'</span><strong>Expected €'+((d.expected_impact_cents||0)/100).toFixed(0)+'</strong></div></section>':'');
}
async function runLiveOperator(){
 try{
  const decisionId=await ownerRpc("owner_operator_prepare",{});
  const prepared=await loadLiveOperator();renderModule("operator");
  const ok=confirm("Approve this live Operator action? It will record and execute the decision in the business database. No external messages or payments will be sent.");
  if(!ok){toast("Live plan prepared","Decision saved but not executed.");return;}
  await ownerRpc("owner_operator_execute",{p_decision_id:decisionId});
  await ownerRpc("owner_operator_measure",{p_decision_id:decisionId});
  await loadLiveOperator();await loadOwnerDashboard();renderModule("operator");
  toast("Operator action executed","Decision Log updated · "+(outreach?.prepared||0)+" outreach drafts prepared · no messages sent yet");
 }catch(e){console.error(e);toast("Operator action failed","No live action was applied.");}
}
function startExecution() {
  state.plan = "executing";
  let steps = [
    "Analyzing customers…",
    "Matching customers with capacity…",
    "Creating personalized campaigns…",
    "Checking owner permissions…",
    "Executing approved actions…",
  ];
  let i = 0;
  $("#moduleContent").innerHTML =
    '<section class="execution-screen"><span class="eyebrow">PLAN EXECUTION · DEMO</span><h2>Operator is executing the approved plan.</h2><p>Every step is constrained by your goals and permissions.</p><div id="executionSteps">' +
    steps
      .map(
        (s, n) =>
          '<div class="' +
          (n === 0 ? "running" : "") +
          '"><i>' +
          (n === 0 ? "◌" : "") +
          "</i><span>" +
          s +
          "</span><b></b></div>",
      )
      .join("") +
    '</div><div class="execution-foot"><span id="executionCount">1 of 5</span><small>Do not close this demo flow</small></div></section>';
  let timer = setInterval(() => {
    let rows = $$("#executionSteps>div");
    rows[i].className = "done";
    rows[i].querySelector("i").textContent = "✓";
    rows[i].querySelector("b").textContent = "Complete";
    i++;
    if (i < steps.length) {
      rows[i].className = "running";
      rows[i].querySelector("i").textContent = "◌";
      $("#executionCount").textContent = i + 1 + " of 5";
    } else {
      clearInterval(timer);
      setTimeout(completePlan, 500);
    }
  }, 650);
}
function completePlan() {
  state.plan = "active";
  state.forecast = 25180;
  state.gap = -180;
  state.impact = 4820;
  state.appointments += 5;
  state.filled = 17;
  state.recoveredCustomers = 31;
  state.ownerHours = 19.4;
  saveDemoState();
  $("#moduleContent").innerHTML =
    '<section class="plan-activated"><div class="activation-check">✓</div><span>PLAN ACTIVATED</span><h2>Revenue goal is back on track.</h2><p>The Operator updated capacity, customer outreach and forecast across the system.</p><div class="activation-metrics"><div><small>FORECAST</small><b>€23,680 → €25,180</b></div><div><small>NEW BOOKINGS</small><b>+5</b></div><div><small>EXPECTED IMPACT</small><b>+€1,500</b></div></div><div class="plan-actions"><button class="primary" data-go="calendar">VIEW UPDATED CALENDAR</button><button class="secondary" data-go="impact">VIEW IMPACT</button><button class="secondary" data-go="decisions">DECISION LOG</button></div></section>';
  bind();
}
function act(a, e) {
  if (a === "new-appointment") return act("manual-booking", e);
  if (a === "demo-directions") return toast("Demo location", "Directions are simulated · no real address is exposed");
  if (a === "reschedule") return toast("Reschedule prepared", "DEMO: choose a new time from Calendar");
  if (a === "cancel-booking") { closeDrawer(); return toast("Cancellation prepared", "DEMO: no real booking affected"); }
  if (a === "add-walkin") return toast("Walk-in added", "DEMO queue updated");
  if (a === "add-block") return toast("Calendar block created", "DEMO availability updated");
  if (a === "capacity") return renderModule("operator");
  if (a === "rebook-client") return renderModule("operator");
  if (a === "add-staff") return toast("Staff draft created", "DEMO staff profile prepared");
  if (a === "coach") return toast("Coaching plan prepared", "DEMO performance action created");
  if (a === "new-campaign") return renderModule("operator");
  if (a === "stock-order") { state.poPrepared=true; saveDemoState(); return toast("Stock order prepared", "DEMO purchase order awaiting approval"); }
  if (a === "match") return toast("Match complete", "DEMO waitlist candidates ranked");
  if (a === "content") return toast("Content prepared", "DEMO campaign copy generated");
  if (a === "pricing") return toast("Pricing simulation ready", "DEMO only · no live prices changed");
  if (a === "coverage-booking") return renderModule("calendar");
  if (a === "coverage-crm") return renderModule("customers");
  if (a === "coverage-payments") return renderModule("money");
  if (a === "coverage-operations") return renderModule("live");
  if (a === "coverage-growth") return renderModule("operator");
  if (a === "manual-booking")
    return openDrawer(
      '<span class="drawer-kicker">MANUAL CONTROL · WORKING DEMO</span><h2>Create appointment</h2><p class="muted">The Operator can do this from a goal, but full manual control remains available.</p><div class="drawer-section"><div class="detail-grid"><div><small>CUSTOMER</small><b>Demo Customer A</b></div><div><small>SERVICE</small><b>Classic Cut · €42</b></div><div><small>STAFF</small><b>Demo Barber B</b></div><div><small>TIME</small><b>Today · 18:00</b></div></div></div><button class="primary" data-action="confirm-manual">CREATE BOOKING</button>',
    );
  if (a === "confirm-manual") {
    Object.assign(state, {
      manualBooking: true,
      appointments: state.appointments + 1,
      forecast: state.forecast + 42,
      gap: state.gap - 42,
    });
    saveDemoState();
    closeDrawer();
    renderModule("calendar");
    return toast(
      "Booking created",
      "Calendar and revenue forecast updated · +€42",
    );
  }
  if (a === "core-recurring") {
    Object.assign(state, {
      recurringCreated: true,
      appointments: state.appointments + 4,
      forecast: state.forecast + 168,
      gap: state.gap - 168,
    });
    saveDemoState();
    renderModule("core");
    return toast(
      "Recurring series created",
      "4 visits · Calendar and forecast updated · +€168",
    );
  }
  if (a === "core-group") {
    Object.assign(state, {
      groupCreated: true,
      appointments: state.appointments + 3,
      forecast: state.forecast + 156,
      gap: state.gap - 156,
    });
    saveDemoState();
    renderModule("core");
    return toast("Group booking reserved", "3 customers · 2 resources · +€156");
  }
  if (a === "core-form") {
    state.formSent = true; saveDemoState();
    renderModule("core");
    return toast(
      "Consultation completed",
      "Signed consent attached to customer timeline",
    );
  }
  if (a === "core-refund") {
    state.refundPending = true; saveDemoState();
    renderModule("core");
    return toast(
      "Decision required",
      "€42 refund is outside automatic permissions",
    );
  }
  if (a === "core-purchase") {
    state.poPrepared = true; saveDemoState();
    renderModule("core");
    return toast(
      "Purchase order prepared",
      "18 units · €126 · owner approval required",
    );
  }
  if (a === "core-split")
    return openDrawer(
      '<span class="drawer-kicker">SPLIT PAYMENT · SIMULATED FEATURE</span><h2>€70 checkout</h2><div class="drawer-section"><div class="attribution-mini"><span>Card</span><b>€40</b></div><div class="attribution-mini"><span>Cash</span><b>€30</b></div></div><button class="primary" data-action="close-drawer">RECORD PAYMENT</button>',
    );
  if (a === "core-package") {
    if (state.packageCredits > 0) state.packageCredits--;
    renderModule("core");
    return toast(
      "Package redeemed",
      state.packageCredits + " credits remaining",
    );
  }
  if (a === "core-loyalty") {
    state.loyaltyPoints += 50;
    renderModule("core");
    saveDemoState();return toast("Loyalty updated", "Visit completed · +50 points");
  }
  if (a === "core-report-plan") return renderModule("operator");
  if (a === "core-guest") return setView("booking");
  if (a === "core-locations") return renderModule("locations");
  if (a === "core-profile") return renderModule("customers");
  if (a.startsWith("coverage-"))
    return openDrawer(
      '<span class="drawer-kicker">COMPETITIVE COVERAGE · INTERNAL</span><h2>' +
        e.closest(".coverage-row").querySelector("b").textContent +
        '</h2><p class="muted">Evidence is mapped feature-by-feature in the audit workbook. Coverage includes working and simulated demo states; planned production items are not counted as implemented.</p><div class="drawer-section"><h3>Operator enhancement</h3><p>' +
        e.closest(".coverage-row").children[3].textContent +
        '</p></div><div class="detail-grid"><div><small>CRITICAL GAP</small><b>None in target architecture</b></div><div><small>PRODUCTION CLAIM</small><b>Not asserted</b></div></div>',
    );
  if (a.startsWith("core-")) {
    const card = e.closest(".core-card");
    return openDrawer(
      '<span class="drawer-kicker">MANUAL CONTROL · ' +
        (card?.querySelector("em")?.textContent || "DEMO") +
        "</span><h2>" +
        (card?.querySelector("h3")?.textContent || "Capability") +
        '</h2><p class="muted">This control is discoverable in the complete platform layer. The Operator uses the same permissioned action when it can safely reduce owner workload.</p><button class="primary" data-action="close-drawer">DONE</button>',
    );
  }
  if (a === "approve-plan") return (!ownerDemoMode && ownerAccessToken) ? runLiveOperator() : startExecution();
  if (a === "view-results") return renderModule("impact");
  if (a === "reset-demo") {
    Object.assign(state, {
      plan: "prepared",
      forecast: 23680,
      gap: 1320,
      impact: 3320,
      appointments: 312,
      filled: 12,
      recoveredCustomers: 19,
      ownerHours: 13.8,
      liveSlotFilled: false,
      recurringCreated: false,
      groupCreated: false,
      formSent: false,
      manualBooking: false,
      refundPending: false,
      poPrepared: false,
      loyaltyPoints: 420,
      packageCredits: 3,
    });
    clearDemoState(); saveDemoState();
    return renderModule("home");
  }
  if (a === "reasoning")
    return openDrawer(
      '<span class="drawer-kicker">OPERATOR REASONING · DEMO DATA</span><h2>Why this plan?</h2><div class="drawer-section"><h3>1 · Close the gap without broad discounting</h3><p>Business Memory shows personalized rebooking performs 2.3× better than discounts and preserves margin.</p></div><div class="drawer-section"><h3>2 · Use existing capacity first</h3><p>Tuesday–Thursday utilization is 61%, so hiring or extra acquisition spend is not the first move.</p></div><div class="drawer-section"><h3>3 · Stay within owner rules</h3><p>€47 marketing cost is below the €100 weekly automatic threshold. No price, refund or staff schedule change is included.</p></div><div class="detail-grid"><div><small>CONFIDENCE</small><b>78%</b></div><div><small>RISK</small><b>Low</b></div></div>',
    );
  if (a === "modify-plan")
    return openDrawer(
      '<span class="drawer-kicker">MODIFY PLAN</span><h2>Change constraints, not tasks.</h2><p class="muted">The Operator will rebuild the plan from your desired outcome.</p><div class="drawer-section"><label>Maximum marketing spend<input value="€47" style="width:100%;padding:12px;margin-top:8px;border:1px solid #ddd"></label></div><div class="drawer-section"><label>Minimum margin<input value="22%" style="width:100%;padding:12px;margin-top:8px;border:1px solid #ddd"></label></div><div class="drawer-actions"><button class="confirm" data-action="save-modified">REBUILD PLAN</button><button data-action="close-drawer">Cancel</button></div>',
    );
  if (a === "save-modified") {
    closeDrawer();
    return toast("Plan rebuilt", "Goals and constraints preserved");
  }
  if (a === "reject-plan") {
    state.plan = "rejected"; saveDemoState();
    return toast(
      "Plan rejected",
      "No actions were executed. Reason saved for learning.",
    );
  }
  if (a === "fill-live-slot") {
    if(state.liveSlotFilled) return toast("Slot already recovered","Duplicate AI attribution prevented");
    state.liveSlotFilled=true; state.appointments++; state.forecast+=45; state.gap=Math.max(0,state.gap-45); state.impact+=45; state.filled++;
    saveDemoState(); renderModule("live");
    return toast("Cancellation recovered","€45 forecast + AI-attributed impact recorded");
  }
  if (a === "impact-detail")
    return openDrawer(
      '<span class="drawer-kicker">ATTRIBUTION TRAIL · DEMO DATA</span><h2>Cycle-aware reactivation</h2><p class="muted">Every outcome links to the approved action and resulting booking.</p><div class="drawer-section"><div class="attribution-mini"><span>Demo Customer B · WhatsApp rebook</span><b>€42</b></div><div class="attribution-mini"><span>Demo Customer C · SMS reactivation</span><b>€52</b></div><div class="attribution-mini"><span>Demo Customer D · membership return</span><b>€64</b></div></div><div class="detail-grid"><div><small>COST</small><b>€18</b></div><div><small>ATTRIBUTED</small><b>€540</b></div></div>',
    );
  if (a === "diagnose-location")
    return openDrawer(
      '<span class="drawer-kicker">VIENNA WEST DIAGNOSIS</span><h2>Retention, not demand, is the constraint.</h2><p>Rebooking is 14 points below network average. Demo Barber B has €2,100 monthly spare capacity.</p><div class="drawer-section"><h3>Prepared plan</h3><p>Cycle-aware rebooking · staff coaching · Thursday capacity campaign. No price change.</p></div><button class="primary" data-action="save-modified">PREPARE FOR APPROVAL</button>',
    );
  if (a === "goal-improve" || a === "reactivate" || a === "staff-plan")
    return renderModule("operator");
  if (a === "close-drawer") return closeDrawer();
  if (a === "appointment") return appointment();
  if (a === "open-checkout") {
    closeDrawer();
    return renderModule("money");
  }
  if (a === "fill-gap") {
    if(state.liveSlotFilled) return toast("Slot already filled","No duplicate booking created");
    state.liveSlotFilled=true; state.appointments++; state.forecast+=42; state.impact+=42; state.filled++;
    saveDemoState(); renderModule(state.module==="today"?"today":"live");
    return toast("Empty slot filled","Demo Waitlist Guest accepted · +€42 forecast and attributed impact");
  }
  if (a === "run-brief") return renderModule("operator");
  if (a === "campaign") return renderModule("operator");
  if (a === "send-campaign") {
    closeDrawer();
    return toast("Campaign started", "14 personalized messages · approved");
  }
  if (a === "risk")
    return openDrawer(
      '<span class="drawer-kicker">NO-SHOW RISK ENGINE</span><h2>2 bookings need review</h2><p class="muted">Explainable risk; no automatic punishment.</p><div class="drawer-section"><h3>Demo Risk Guest · 14:30 · 68% risk</h3><p>2 late cancellations · new phone number · peak 60-minute service.</p><button class="primary small" data-action="preauth">Request €52 pre-auth</button></div>',
    );
  if (a === "preauth") {
    closeDrawer();
    return toast("Pre-auth sent", "Demo Risk Guest has 30 minutes to confirm");
  }
  if (a === "add-product") {
    state.addon = 18;
    $(".addon-line").classList.remove("hidden");
    e.disabled = true;
    e.textContent = "Added";
    return checkout();
  }
  if (a === "pay") {
    if(state.ownerPaymentRecorded) return toast("Payment already recorded","Duplicate demo charge prevented");
    state.ownerPaymentRecorded=true; const amount=52+state.addon; state.current+=amount; saveDemoState();
    return toast("SIMULATED payment recorded", money(amount)+" · no real charge · Money state updated");
  }
  if (a === "message-client")
    return toast("Message prepared", "WhatsApp · owner approval not required");
  if (a === "invite-waitlist") {
    if(state.waitlistInvited) return toast("Invite already active","Demo slot remains reserved");
    state.waitlistInvited=true; saveDemoState();
    return toast("Demo waitlist invite sent","Slot reserved for Demo Waitlist Guest for 15 minutes");
  }
  if (a === "reorder") { state.poPrepared=true; saveDemoState(); return toast("Purchase order prepared", "Approval required above €50"); }
  if (a === "reviews")
    return toast("Review flow active", "14 requests scheduled");
  if (a === "save-settings") { saveDemoState(); return toast("Settings saved", "Rules and channels synchronized"); }
  if (a === "master-apply")
    return toast(
      "SIMULATED network playbook",
      "Demo approval scenario prepared · no real businesses affected",
    );
  if (a) return toast("Demo feature", "This control is intentionally simulated in the current product demo.");
}
function checkout() {
  let s = 52 + state.addon,
    t = s * (1 + state.tip / 100);
  if ($("#checkoutTotal")) $("#checkoutTotal").textContent = money(s);
  if ($("#payAmount")) $("#payAmount").textContent = money(t);
}
const SUPABASE_URL="https://lpnewhfsbpwyjgdpoxqj.supabase.co";
const SUPABASE_KEY="sb_publishable_3FRbG5Y2r1K_iLK27KErIQ_1CMH1a0Q";
const BOOKING_BUSINESS="demo-studio";
const SERVICE_SLUGS={"Classic Cut":"classic-cut","Skin Fade":"skin-fade","Cut + Beard":"cut-beard","Beard Ritual":"beard-ritual"};
const STAFF_SLUGS={"Demo Barber A":"demo-barber-a","Demo Barber B":"demo-barber-b","Demo Barber C":"demo-barber-c"};
let bookingDate="2026-09-23";

async function supabaseRpc(fn,params){
  const res=await fetch(SUPABASE_URL+"/rest/v1/rpc/"+fn,{method:"POST",headers:{"apikey":SUPABASE_KEY,"Authorization":"Bearer "+SUPABASE_KEY,"Content-Type":"application/json"},body:JSON.stringify(params)});
  const body=await res.text(); if(!res.ok) throw new Error(body||("HTTP "+res.status)); return body?JSON.parse(body):null;
}
function selectedStaffSlug(){return STAFF_SLUGS[state.barber]||"demo-barber-a"}
function selectedServiceSlug(){return SERVICE_SLUGS[state.service]||"skin-fade"}
async function refreshLiveAvailability(){
  if(!state.service||!state.barber||state.barber==="First available") return;
  try{
    const slots=await supabaseRpc("get_public_availability",{p_business_slug:BOOKING_BUSINESS,p_staff_slug:selectedStaffSlug(),p_service_slug:selectedServiceSlug(),p_date:bookingDate});
    const grid=$(".slot-grid"); if(!grid)return;
    grid.innerHTML=(slots||[]).slice(0,12).map(t=>'<button data-time="'+t+'">'+t+'</button>').join("") || '<span class="muted">No available times</span>';
    $("#booking .slot-grid [data-time]").forEach(b=>b.onclick=()=>{ $("#booking .slot-grid [data-time]").forEach(x=>x.classList.remove("selected"));b.classList.add("selected");state.time=b.dataset.time;$("#sumTime").textContent=bookingDate+" · "+state.time;bookingChoiceConfirm(state.time+" selected");state.bookStep=4;bookRefresh();});
  }catch(e){console.error("Live availability",e);}
}
async function createLiveBooking(guestName,guestPhone){
  const startsAt=bookingDate+"T"+state.time+":00+02:00";
  return await supabaseRpc("create_public_booking",{p_business_slug:BOOKING_BUSINESS,p_staff_slug:selectedStaffSlug(),p_service_slug:selectedServiceSlug(),p_starts_at:startsAt,p_display_name:guestName,p_email:null,p_phone:guestPhone});
}

let ownerAccessToken=null, ownerDashboardData=null, ownerMetrics=null, ownerCrm=[], ownerRebooking=[], ownerDemoMode=false;
function ownerAuthHeaders(){return {"apikey":SUPABASE_KEY,"Authorization":"Bearer "+ownerAccessToken,"Content-Type":"application/json"}}
function parseAuthHash(){
  const raw=(location.hash||"").replace(/^#/,""); if(!raw)return;
  const q=new URLSearchParams(raw); const token=q.get("access_token"); if(token){ownerAccessToken=token;sessionStorage.setItem("operator-owner-token",token);history.replaceState(null,"",location.pathname+location.search);}
}
async function ownerRpc(fn,params={}){
 const res=await fetch(SUPABASE_URL+"/rest/v1/rpc/"+fn,{method:"POST",headers:ownerAuthHeaders(),body:JSON.stringify(params)});
 if(res.status===401)throw new Error("AUTH_REQUIRED"); const t=await res.text();if(!res.ok)throw new Error(t||("HTTP "+res.status));return t?JSON.parse(t):null;
}
async function loadOwnerDashboard(){
 if(!ownerAccessToken)return null;
 const data=await ownerRpc("owner_dashboard",{}); ownerDashboardData=data; return data;
}
function showOwnerApp(demo=false){
 ownerDemoMode=demo; $("#ownerAuthGate")?.classList.add("hidden"); $("#ownerAppShell")?.classList.remove("hidden");
 if(demo){renderModule(window.__pendingModule||"home");return;}
 Promise.all([loadOwnerDashboard(),ownerRpc("owner_business_metrics",{}).catch(()=>null),ownerRpc("owner_customer_crm",{}).catch(()=>[]),ownerRpc("owner_rebooking_opportunities",{}).catch(()=>[])]).then(([data,metrics,crm,rebooking])=>{ ownerMetrics=metrics; ownerCrm=crm||[]; ownerRebooking=rebooking||[];
   if(!data){sessionStorage.removeItem("operator-owner-token");ownerAccessToken=null;showOwnerGate("This account is not connected to a business yet.");return;}
   const brand=$(".brand small");if(brand)brand.textContent=(data.business?.name||"BUSINESS")+" · LIVE";
   const owner=$(".owner small");if(owner)owner.textContent=(data.business?.role||"owner").toUpperCase()+" · LIVE BACKEND";
   renderModule(window.__pendingModule||"home");
 }).catch(()=>{sessionStorage.removeItem("operator-owner-token");ownerAccessToken=null;showOwnerGate("Sign-in expired. Request a new secure link.");});
}
function showOwnerGate(message=""){
 $("#ownerAppShell")?.classList.add("hidden");$("#ownerAuthGate")?.classList.remove("hidden");const s=$("#ownerAuthStatus");if(s)s.textContent=message;
}
async function sendOwnerMagicLink(){
 const email=$("#ownerEmail")?.value?.trim();if(!email)return showOwnerGate("Enter your owner email.");
 const btn=$("#ownerLoginBtn");if(btn)btn.disabled=true;
 try{
  const res=await fetch(SUPABASE_URL+"/auth/v1/otp",{method:"POST",headers:{"apikey":SUPABASE_KEY,"Content-Type":"application/json"},body:JSON.stringify({email,create_user:false,gotrue_meta_security:{captcha_token:null}})});
  if(!res.ok)throw new Error(await res.text());showOwnerGate("Secure sign-in link sent. Open it on this device.");
 }catch(e){showOwnerGate("Could not send the sign-in link. Only provisioned owner accounts can sign in.");}
 finally{if(btn)btn.disabled=false;}
}
async function refreshOwnerLive(){ownerDashboardData=await loadOwnerDashboard();try{[ownerMetrics,ownerCrm,ownerRebooking]=await Promise.all([ownerRpc("owner_business_metrics",{}),ownerRpc("owner_customer_crm",{}),ownerRpc("owner_rebooking_opportunities",{})])}catch(e){ownerMetrics=null}renderModule(state.module||"home")}
function ownerBookingModal(mode,b=null){
 if(ownerDemoMode||!ownerDashboardData)return toast("Live owner account required","Use secure owner sign-in to change live bookings.");
 const staff=(ownerDashboardData.staff||[]).map(x=>'<option value="'+x.id+'" '+(b&&x.display_name===b.staff?"selected":"")+'>'+x.display_name+'</option>').join("");
 const services=(ownerDashboardData.services||[]).map(x=>'<option value="'+x.id+'" '+(b&&x.name===b.service?"selected":"")+'>'+x.name+' · €'+(x.price_cents/100).toFixed(0)+'</option>').join("");
 const start=b?new Date(b.starts_at).toISOString().slice(0,16):"";
 const wrap=document.createElement("div");wrap.className="live-booking-modal";
 wrap.innerHTML='<div class="live-booking-card"><button class="modal-close" type="button">×</button><small>LIVE DATABASE</small><h2>'+(mode==="create"?"New booking":"Manage booking")+'</h2>'+
 (mode==="create"?'<label>Customer<input id="liveCustomer" value="Demo Guest"></label><label>Professional<select id="liveStaff">'+staff+'</select></label><label>Service<select id="liveService">'+services+'</select></label>':'<p><b>'+b.customer+'</b><br>'+b.service+' · '+b.staff+'</p>')+
 '<label>Date & time<input id="liveStart" type="datetime-local" value="'+start+'"></label><div class="modal-actions">'+
 (mode==="create"?'<button class="primary" id="liveSave">Create booking</button>':'<button class="primary" id="liveMove">Reschedule</button><button class="secondary" id="liveComplete">Complete</button><button class="secondary" id="liveNoShow">No-show</button><button class="secondary" id="liveCancel">Cancel booking</button>')+'</div><span id="liveBookingStatus"></span></div>';
 document.body.appendChild(wrap);wrap.querySelector(".modal-close").onclick=()=>wrap.remove();
 const status=t=>{const s=wrap.querySelector("#liveBookingStatus");if(s)s.textContent=t};
 if(mode==="create")wrap.querySelector("#liveSave").onclick=async()=>{try{status("Saving…");await ownerRpc("owner_create_booking",{p_business_id:ownerDashboardData.business.id,p_staff_id:wrap.querySelector("#liveStaff").value,p_service_id:wrap.querySelector("#liveService").value,p_starts_at:new Date(wrap.querySelector("#liveStart").value).toISOString(),p_customer_name:wrap.querySelector("#liveCustomer").value});wrap.remove();await refreshOwnerLive();toast("Booking created","Saved to live database");}catch(e){status(e.message.includes("SLOT_ALREADY_BOOKED")?"That time is already booked.":"Could not create booking.");}};
 else{
  wrap.querySelector("#liveMove").onclick=async()=>{try{status("Saving…");await ownerRpc("owner_reschedule_booking",{p_booking_id:b.id,p_starts_at:new Date(wrap.querySelector("#liveStart").value).toISOString()});wrap.remove();await refreshOwnerLive();toast("Booking rescheduled","Live database updated");}catch(e){status(e.message.includes("SLOT_ALREADY_BOOKED")?"That time is already booked.":"Could not reschedule booking.");}};
  wrap.querySelector("#liveComplete").onclick=async()=>{try{status("Saving…");await ownerRpc("owner_update_booking_status",{p_booking_id:b.id,p_status:"completed"});wrap.remove();await refreshOwnerLive();toast("Appointment completed","Revenue is now verified in live metrics");}catch(e){status("Could not update booking.");}};\n  wrap.querySelector("#liveNoShow").onclick=async()=>{try{status("Saving…");await ownerRpc("owner_update_booking_status",{p_booking_id:b.id,p_status:"no_show"});wrap.remove();await refreshOwnerLive();toast("Marked as no-show","Live metrics updated");}catch(e){status("Could not update booking.");}};\n  wrap.querySelector("#liveCancel").onclick=async()=>{try{status("Cancelling…");await ownerRpc("owner_cancel_booking",{p_booking_id:b.id});wrap.remove();await refreshOwnerLive();toast("Booking cancelled","Live database updated");}catch(e){status("Could not cancel booking.");}};
 }
}
function bindLiveOwnerRows(){
 $("[data-live-booking-id]").forEach(el=>el.onclick=()=>{const b=(ownerDashboardData?.bookings||[]).find(x=>x.id===el.dataset.liveBookingId);if(b)ownerBookingModal("manage",b)});
}
function escLive(v){return String(v??"").replace(/[&<>"']/g,m=>({"&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;","'":"&#39;"}[m]))}
function liveCrmPanel(){
 if(ownerDemoMode||!ownerAccessToken)return "";
 const due=(ownerRebooking||[]).slice(0,6);
 const customers=(ownerCrm||[]).slice(0,8);
 return '<section class="live-crm"><div class="live-crm-head"><div><small>LIVE CRM</small><h3>Customer Intelligence</h3></div><span>'+(ownerCrm||[]).length+' customers</span></div>'+
 '<div class="crm-columns"><div><h4>Rebooking opportunities</h4>'+(due.length?due.map(x=>'<button class="crm-row" data-crm-customer="'+x.customer_id+'"><b>'+escLive(x.display_name)+'</b><span>'+escLive(x.service||"Service")+' · '+escLive(x.status)+'</span><em>'+escLive(x.reason)+'</em></button>').join(""):'<p class="muted">No due customers yet. Complete appointments to build rebooking intelligence.</p>')+'</div>'+
 '<div><h4>Customer memory</h4>'+(customers.length?customers.map(x=>'<button class="crm-row" data-crm-customer="'+x.id+'"><b>'+escLive(x.display_name)+'</b><span>'+(x.visit_count||0)+' visits · €'+((x.lifetime_value_cents||0)/100).toFixed(0)+' LTV</span><em>'+escLive(x.cut_memory||x.preferred_service||"No Cut Memory yet")+'</em></button>').join(""):'<p class="muted">No live customer history yet.</p>')+'</div></div></section>';
}
function bindLiveCrm(){
 $("#moduleContent [data-crm-customer]").forEach(btn=>btn.onclick=()=>{
  const c=(ownerCrm||[]).find(x=>x.id===btn.dataset.crmCustomer); if(!c)return;
  const notes=prompt("Cut Memory notes",c.cut_memory||""); if(notes===null)return;
  const days=prompt("Expected rebooking cycle (days)",String(c.rebook_interval_days||28)); if(days===null)return;
  ownerRpc("owner_save_cut_memory",{p_customer_id:c.id,p_notes:notes,p_rebook_interval_days:Number(days)||28}).then(()=>refreshOwnerLive()).then(()=>toast("Cut Memory saved","Rebooking intelligence updated")).catch(e=>toast("Could not save",e.message));
 });
}
function liveMetricsPanel(){
 if(ownerDemoMode||!ownerMetrics)return "";
 const m=ownerMetrics;
 return '<section class="live-metric-grid"><div><small>TODAY</small><b>'+m.today_bookings+'</b><span>bookings</span></div><div><small>NEXT 7 DAYS</small><b>'+m.next_7_days+'</b><span>confirmed</span></div><div><small>BOOKED REVENUE</small><b>€'+((m.booked_revenue_cents||0)/100).toFixed(0)+'</b><span>this month</span></div><div><small>COMPLETED REVENUE</small><b>€'+((m.completed_revenue_cents||0)/100).toFixed(0)+'</b><span>verified</span></div><div><small>NO-SHOWS</small><b>'+m.no_shows_month+'</b><span>this month</span></div></section>';
}
function liveOwnerPanel(){
 const d=ownerDashboardData;if(!d)return "";
 const rows=(d.bookings||[]).slice(0,8).map(b=>'<div class="guest-event" data-live-booking-id="'+b.id+'"><b>'+new Date(b.starts_at).toLocaleString("en-GB",{day:"2-digit",month:"short",hour:"2-digit",minute:"2-digit"})+'</b><span>'+b.customer+' · '+b.service+' · '+b.staff+'</span><strong>'+b.status.toUpperCase()+'</strong></div>').join("");
 return '<section class="synced-booking"><div><span>LIVE BUSINESS DATA · SUPABASE</span><h3>'+d.business.name+'</h3><p>'+d.counts.bookings+' bookings · '+d.counts.customers+' customers · '+d.counts.staff+' staff · '+d.counts.services+' services</p></div><b>LIVE</b></section>'+(rows?'<section class="guest-audit-trail"><div class="panel-head"><h2>Live bookings</h2><span class="demo-chip">DATABASE</span></div>'+rows+'</section>':'');
}
parseAuthHash();
ownerAccessToken=ownerAccessToken||sessionStorage.getItem("operator-owner-token");
document.addEventListener("DOMContentLoaded",()=>{
 $("#ownerLoginBtn")?.addEventListener("click",sendOwnerMagicLink);
 $("#ownerDemoBtn")?.addEventListener("click",()=>showOwnerApp(true));
 $("#ownerSignOut")?.addEventListener("click",()=>{sessionStorage.removeItem("operator-owner-token");ownerAccessToken=null;ownerDashboardData=null;showOwnerGate("Signed out.");});
 if(ownerAccessToken)showOwnerApp(false);else showOwnerGate();
});

function bookingChoiceConfirm(label) {
  let el = $("#bookingChoiceConfirm");
  if (!el) { el = document.createElement("div"); el.id="bookingChoiceConfirm"; el.className="choice-confirm"; $("#booking")?.appendChild(el); }
  el.textContent = "✓ " + label;
  el.classList.remove("show"); void el.offsetWidth; el.classList.add("show");
  clearTimeout(window.__bookingChoiceTimer); window.__bookingChoiceTimer=setTimeout(()=>el.classList.remove("show"),700);
}
function bookRefresh() {
  $$(".book-step").forEach((s, i) =>
    s.classList.toggle("hidden", i !== state.bookStep - 1),
  );
  $$(".stepper span").forEach((s, i) =>
    s.classList.toggle("active", i < state.bookStep),
  );
  $("#bookBack").disabled = state.bookStep === 1;
  const progress=$("#bookProgress"); if(progress) progress.textContent=String(state.bookStep).padStart(2,"0")+" / 04";
  let ok = [
    state.service,
    state.barber,
    state.time,
    $("#guestName").value.trim() && $("#guestPhone").value.trim(),
  ][state.bookStep - 1];
  $("#bookNext").disabled = !ok;
  $("#bookNext").textContent =
    state.bookStep === 4 ? "€10 Deposit bezahlen" : "Weiter";
}
$$("[data-service]").forEach(b => b.onclick = () => {
  $$("[data-service]").forEach(x => x.classList.remove("selected"));
  b.classList.add("selected"); state.service=b.dataset.service; state.price=+b.dataset.price;
  $("#sumService").textContent=state.service; $("#sumPrice").textContent=money(state.price);
  bookingChoiceConfirm(state.service+" selected"); state.bookStep=2; bookRefresh();
});
$$("[data-barber]").forEach(b => b.onclick = () => {
  $$("[data-barber]").forEach(x => x.classList.remove("selected"));
  b.classList.add("selected"); state.barber=b.dataset.barber; $("#sumBarber").textContent=state.barber;
  const quickTime=b.querySelector(".next-slot strong")?.textContent?.match(/(\d{2}:\d{2})/)?.[1]; if(quickTime){state.time=quickTime; $("#sumTime").textContent="Demo date · "+state.time;}
  bookingChoiceConfirm(state.barber+" · "+(quickTime||"selected")); state.bookStep=3; bookRefresh();
});
$$("[data-time]").forEach(b => b.onclick = () => {
  $$("[data-time]").forEach(x => x.classList.remove("selected"));
  b.classList.add("selected"); state.time=b.dataset.time; $("#sumTime").textContent="Demo date · "+state.time;
  bookingChoiceConfirm(state.time+" selected"); state.bookStep=4; bookRefresh();
});
$$(".date-strip button").forEach(
  (b) =>
    (b.onclick = () => {
      $$(".date-strip button").forEach((x) => x.classList.remove("active"));
      b.classList.add("active");
    }),
);
$("#bookBack").onclick = () => {
  if (state.bookStep > 1) {
    state.bookStep--;
    bookRefresh();
  }
};
$("#bookNext").onclick = async () => {
  if (state.bookStep < 4) { state.bookStep++; bookRefresh(); return; }
  const guestName=(($("#guestName")?.value)||"Guest").trim()||"Guest";
  const guestPhone=(($("#guestPhone")?.value)||"").trim();
  const btn=$("#bookNext"); if(btn){btn.disabled=true;btn.setAttribute("aria-busy","true");}
  try{
    const bookingId=await createLiveBooking(guestName,guestPhone);
    state.guestDeposit=0; state.guestPaymentStatus="not_charged";
    state.guestBooking={id:bookingId,customer:guestName,service:state.service,price:state.price,barber:state.barber,time:state.time,deposit:0,remaining:state.price,status:"Confirmed",backend:"supabase"};
    state.guestEvents.unshift({type:"BOOKING",result:"Confirmed · €"+state.price,detail:"LIVE DATABASE · "+state.service+" · "+state.barber+" · "+state.time});
    state.appointments++; state.forecast+=state.price; saveDemoState();
    $(".book-step").forEach(x=>x.classList.add("hidden")); $("#bookActions")?.classList.add("hidden"); $("#bookingSuccess")?.classList.remove("hidden");
    const p=$("#bookingSuccess p"); if(p)p.innerHTML="<b>BOOKING SAVED TO LIVE DATABASE</b><br>No real payment was charged. Payment remains simulated until a payment provider is connected.";
    bindGuestActions(); toast(state.guestLang==="EN"?"Booking confirmed":"Buchung bestätigt","Saved to live booking database · no real charge");
  }catch(e){
    console.error(e); toast(state.guestLang==="EN"?"Time no longer available":"Termin nicht mehr verfügbar",state.guestLang==="EN"?"Choose another available time.":"Bitte wähle einen anderen freien Termin.");
    state.bookStep=3; bookRefresh(); await refreshLiveAvailability();
  }finally{if(btn){btn.removeAttribute("aria-busy");bookRefresh();}}
};
["guestName", "guestPhone"].forEach(
  (id) => ($("#" + id).oninput = bookRefresh),
);
$(`[data-action="repeat-cut"]`).forEach(btn=>btn.onclick = () => {
  state.service = state.cutMemory.service;
  state.price = 42;
  state.barber = state.cutMemory.barber;
  state.time = state.cutMemory.time;
  $("#sumService").textContent = "Skin Fade";
  $("#sumBarber").textContent = "Demo Barber A";
  $("#sumTime").textContent = "Di, 22. Sep · 16:15";
  $("#sumPrice").textContent = "€42";
  state.bookStep = 4;
  bookRefresh();
  toast(state.guestLang==="EN"?"Cut Memory loaded":"Cut Memory geladen", state.guestLang==="EN"?"Your usual service, professional and time are ready":"Dein üblicher Service, Professional und Termin sind bereit");
});
$('[data-action="waitlist"]').onclick = () => {
  state.guestWaitlist = true; saveDemoState();
  toast(state.guestLang==="EN"?"Smart waitlist active":"Smart-Warteliste aktiv",state.guestLang==="EN"?"DEMO: automatic matching is enabled":"DEMO: automatisches Matching ist aktiviert");
};
$('[data-action="new-booking"]').onclick = () => {
  state.bookStep=1; state.service=""; state.price=0; state.barber=""; state.time="";
  $("#bookingSuccess").classList.add("hidden"); $("#bookActions").classList.remove("hidden");
  $("#sumService").textContent=$("#sumBarber").textContent=$("#sumTime").textContent=$("#sumPrice").textContent="—";
  $$(".selected").forEach(x=>x.classList.remove("selected")); bookRefresh();
};
function bindGuestActions(){
  $$("[data-guest-action]").forEach(b=>b.onclick=()=>guestAction(b.dataset.guestAction));
}
function guestAction(a){
  saveDemoState();
  if(!state.guestBooking) return toast("No active demo booking");
  const b=state.guestBooking;
  if(a==="reschedule"){b.time=b.time==="16:15"?"17:45":"16:15"; state.guestEvents.unshift({type:"RESCHEDULE",result:"Moved to "+b.time,detail:"Owner Calendar synced"}); $("#sumTime").textContent="Demo date · "+b.time; saveDemoState();return toast("Booking rescheduled",b.time+" · Owner Calendar synced");}
  if(a==="cancel"){if(b.status==="Cancelled")return toast("Already cancelled");b.status="Cancelled";state.forecast=Math.max(0,state.forecast-b.price);if(state.guestPaymentStatus==="simulated_paid"&&state.guestDeposit>0){state.current=Math.max(0,state.current-state.guestDeposit);state.guestPaymentStatus="simulated_refunded";b.deposit=0;state.guestDeposit=0;}state.guestEvents.unshift({type:"CANCEL",result:"Slot released",detail:"€10 simulated refund"});saveDemoState();return toast("Booking cancelled","DEMO: calendar released · €10 refund simulated");}
  if(a==="rebook"){if(state.futureBooking)return toast("Next visit already reserved",state.futureBooking.time+" · duplicate prevented");state.futureBooking={service:b.service,price:b.price,barber:b.barber,time:"Demo future visit · 16:15",status:"Confirmed"};state.appointments++;state.forecast+=b.price;state.guestEvents.unshift({type:"REBOOK",result:"+€"+b.price+" forecast",detail:"Future visit reserved"});saveDemoState();return toast("Next visit reserved","DEMO: +1 future appointment · €"+b.price+" forecast");}
  if(a==="pay-tip"){if(b.remaining===0)return toast("Balance already paid");const paid=b.remaining+5;state.current+=paid;b.remaining=0;state.guestEvents.unshift({type:"PAYMENT",result:"€"+paid+" recorded",detail:"Includes €5 demo tip"});saveDemoState();return toast("Demo payment complete","Remaining balance + €5 tip recorded");}
  if(a==="review"){state.guestReview=true;state.guestEvents.unshift({type:"REVIEW",result:"5★ recorded",detail:"Linked to customer timeline"});saveDemoState();return toast("5★ demo review recorded","Review linked to customer timeline");}
  if(a==="loyalty"){state.loyaltyPoints+=50; saveDemoState();return toast("Loyalty updated","+50 demo points");}
  if(a==="membership"){state.guestMembership=true; saveDemoState();return toast("Membership activated","DEMO membership · no real charge");}
  if(a==="gift"){state.guestGift=true; saveDemoState();return toast("Gift card created","DEMO €50 gift card · no real charge");}
}
bindGuestActions();
window.applyGuestLanguage = function applyGuestLanguage(lang){
  state.guestLang=lang;
  const en=lang==="EN";
  const dict={
    ".booking-kicker":en?"PRIVATE BOOKING · NOIR DEMO":"PRIVATE BUCHUNG · NOIR DEMO",
    ".booking-main>h1":en?"Your look.<br><em>Your appointment.</em>":"Dein Look.<br><em>Dein Termin.</em>",
    ".booking-lead":en?"Premium grooming. Book in under a minute.":"Premium Grooming. In weniger als einer Minute gebucht."
  };
  Object.entries(dict).forEach(([s,v])=>{const n=$(s);if(n)n.innerHTML=v});
  const heads=$$(".section-title h2");
  const labels=en?["Choose service","Choose professional","Choose time","Alnow done"]:["Service wählen","Professional wählen","Zeit wählen","Fast geschafft"];
  heads.forEach((n,i)=>{if(labels[i])n.textContent=labels[i]});
  if($("#bookBack")) $("#bookBack").textContent=en?"Back":"Zurück";
  if($("#bookNext")) $("#bookNext").textContent=state.bookStep===4?(en?"Pay €10 demo deposit":"€10 Demo-Deposit bezahlen"):(en?"Continue":"Weiter");
  $$(".lang [data-lang]").forEach(x=>x.classList.toggle("active",x.dataset.lang===lang));
}
$$(".lang [data-lang]").forEach(b=>b.onclick=()=>{applyGuestLanguage(b.dataset.lang);toast(b.dataset.lang==="EN"?"Language changed":"Sprache geändert",b.dataset.lang)});
bind();
renderModule(window.__pendingModule || "home");
bookRefresh();
