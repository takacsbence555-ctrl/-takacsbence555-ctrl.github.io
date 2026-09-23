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
  settings: ["Settings", "Business core, integrations and data protection"],
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
  $$("[data-view]").forEach((b) =>
    b.classList.toggle("active", b.dataset.view === id),
  );
  window.scrollTo({ top: 0, behavior: "smooth" });
}
$$("[data-view]").forEach((b) => (b.onclick = () => setView(b.dataset.view)));
function schedule() {
  return '<div class="schedule"><div></div><div class="shead">Marco</div><div class="shead">Dani</div><div class="shead">Alex</div><div class="hour">10:00</div><div class="appt" data-action="appointment"><b>Tom · Cut</b><small>10:00–10:45</small></div><div></div><div class="appt blue" data-action="appointment"><b>Leon · Fade</b><small>10:00–10:50</small></div><div class="hour">11:00</div><div></div><div class="appt sand" data-action="appointment"><b>Paul · Beard</b><small>11:15–11:45</small></div><div></div><div class="hour">12:00</div><div class="appt blue" data-action="appointment"><b>Noah · Combo</b><small>12:00–13:00</small></div><div></div><div class="appt" data-action="appointment"><b>David · Cut</b><small>12:15–13:00</small></div><div class="hour">14:00</div><div class="appt sand" data-action="appointment"><b>Emil · Fade</b><small>14:00–14:50</small></div><div class="appt blue" data-action="appointment"><b>Max · Cut</b><small>14:00–14:45</small></div><div class="appt risk" data-action="appointment"><b>Leo · Combo</b><small>AI risk · 14:30</small></div></div>';
}
function calendar() {
  let rows = [
    ["10:00", "Tom · Classic Cut", "", "Leon · Skin Fade"],
    ["11:00", "", "Paul · Beard", ""],
    ["12:00", "Noah · Combo", "", "David · Cut"],
    ["13:00", "Lunch", "Lunch", "Lunch"],
    ["14:00", "Emil · Skin Fade", "Max · Classic Cut", "Leo · Combo"],
    ["15:00", "Anna · Undercut", "AI gap · €42", ""],
    ["16:00", "Oskar · Cut", "Bence · Fade", "Mika · Beard"],
    ["17:00", "", "Nico · Cut", "Jan · Combo"],
  ];
  let h =
    '<div class="calendar-grid"><div></div><div class="calhead"><b>Marco</b><small>84% · €248</small></div><div class="calhead"><b>Dani</b><small>91% · €294</small></div><div class="calhead"><b>Alex</b><small>72% · €142</small></div>';
  rows.forEach((r) => {
    h += '<div class="cal-time">' + r[0] + "</div>";
    r.slice(1).forEach((x, i) => {
      h += x
        ? '<div class="cal-card ' +
          (x.includes("gap") ? "gap" : i === 1 ? "blue" : "") +
          " " +
          (x.includes("Leo") ? "risk" : "") +
          '" data-action="' +
          (x.includes("gap") ? "fill-gap" : "appointment") +
          '"><b>' +
          x +
          "</b><small>" +
          (x.includes("gap") ? "6 waitlist match" : "Kattints a részletekért") +
          "</small></div>"
        : "<div></div>";
    });
  });
  return h + "</div>";
}
const modules = {
  today: () =>
    '<section class="ai-brief"><div><span class="spark">✦ AI DAILY BRIEF</span><h2>3 döntés ma +€286 bevételt védhet meg.</h2><p>A rendszer a foglalásokat, vendégciklusokat és üres székeket elemezte.</p></div><div class="brief-points"><span>15:30-as üres hely kitölthető a várólistáról</span><span>2 magas kockázatú foglalás megerősítést kér</span><span>14 vendég esedékes újrafoglalásra</span></div><button data-action="run-brief">Végrehajtási terv →</button></section><div class="grid-4"><article class="kpi"><span>MAI FOGLALÁSOK</span><b>17</b><small>+3 tegnaphoz képest</small></article><article class="kpi"><span>VÁRHATÓ BEVÉTEL</span><b>€684</b><small>82% kihasználtság</small></article><article class="kpi"><span>VISSZATÉRŐK</span><b>71%</b><small>+8% az előző hónaphoz</small></article><article class="kpi"><span>VÉDETT BEVÉTEL</span><b>€104</b><small>no-show védelem</small></article></div><div class="content-grid"><section class="panel"><div class="panel-head"><h2>Mai székterv</h2><button data-go="calendar">Teljes naptár →</button></div>' +
    schedule() +
    '</section><div class="side-stack"><section class="panel opportunity"><small>ÜRES SZÉK LEHETŐSÉG</small><b class="amount">€42</b><p>Dani 15:30-as helyére 6 megfelelő vendég van a várólistán.</p><button data-action="fill-gap">Hely feltöltése AI-val</button></section><section class="panel"><div class="panel-head"><h2>Élő aktivitás</h2><small>most</small></div><div class="activity-list"><div class="activity-row"><i></i><div><b>Új foglalás</b><small>Max · Classic Cut · Dani</small></div><time>2p</time></div><div class="activity-row"><i></i><div><b>Kártya előhitelesítve</b><small>Leon · magasabb kockázat</small></div><time>18p</time></div><div class="activity-row"><i></i><div><b>5★ értékelés</b><small>„Perfekt wie immer”</small></div><time>1ó</time></div></div></section><section class="panel"><div class="panel-head"><h2>Walk-in sor</h2><button data-action="add-walkin">+ Vendég</button></div><div class="walkin"><span><b>Jonas K.</b><small>Skin Fade · 12 perc</small></span><b>Dani</b></div><div class="walkin"><span><b>Walk-in #18</b><small>Classic Cut · 28 perc</small></span><b>Marco</b></div></section></div></div>',
  calendar: () =>
    '<div class="section-bar"><div><h2>Naptár · Szeptember 22.</h2><small class="muted">3 barber · 82% kihasználtság</small></div><div class="filters"><button class="active">Nap</button><button>Hét</button><button>Lista</button><button data-action="add-block">+ Blokk</button></div></div><div class="calendar-board">' +
    calendar() +
    '</div><div class="content-grid"><section class="panel"><div class="panel-head"><h2>Intelligens várólista</h2><small>6 vendég · valós idejű rangsor</small></div><table class="table"><thead><tr><th>VENDÉG</th><th>SZOLGÁLTATÁS</th><th>ELÉRHETŐSÉG</th><th>AI MATCH</th><th></th></tr></thead><tbody><tr><td><b>Felix M.</b></td><td>Skin Fade</td><td>14:00–18:00</td><td><span class="badge">96%</span></td><td><button class="ghost" data-action="invite-waitlist">Meghívás</button></td></tr><tr><td><b>Lucas T.</b></td><td>Classic Cut</td><td>15:00 után</td><td><span class="badge">91%</span></td><td><button class="ghost" data-action="invite-waitlist">Meghívás</button></td></tr></tbody></table></section><section class="panel"><div class="panel-head"><h2>Kapacitásjelzés</h2><span class="badge blue">AI FORECAST</span></div><p class="muted">Péntek 16–19 óra túlfoglalt, szerda délelőtt 31% szabad kapacitás várható.</p><button class="primary small" data-action="capacity">Műszakjavaslat megnyitása</button></section></div>',
  customers: () =>
    '<div class="section-bar"><div><h2>Vendégek</h2><small class="muted">1 284 profil · 71% visszatérő</small></div><div class="filters"><button class="active">Mindenki</button><button>Esedékes 28</button><button>Kockázatos 9</button><button>VIP 42</button></div></div><div class="customer-layout"><section class="customer-list"><div class="list-search"><input placeholder="Vendég keresése…"></div><div class="client-row active"><span class="avatar dark">LM</span><div><b>Leon Müller</b><small>VIP · 12 látogatás · €624</small></div></div><div class="client-row"><span class="avatar lime">MF</span><div><b>Max Fischer</b><small>Esedékes 4 napja · €288</small></div></div><div class="client-row"><span class="avatar sand">PN</span><div><b>Paul Novak</b><small>At-risk · 9 hete nem járt</small></div></div><div class="client-row"><span class="avatar pale">JW</span><div><b>Jonas Weber</b><small>Új vendég · 1 látogatás</small></div></div></section><section class="customer-profile"><div class="profile-top"><div class="profile-name"><span class="avatar dark">LM</span><div><h2>Leon Müller</h2><p>VIP · Dani vendége · Utolsó látogatás: aug. 28.</p></div></div><div class="profile-actions"><button class="ghost" data-action="message-client">Üzenet</button><button class="primary small" data-action="rebook-client">Újrafoglalás</button></div></div><div class="profile-body"><div class="profile-stats"><div class="mini-stat"><span>LÁTOGATÁS</span><b>12</b></div><div class="mini-stat"><span>ÖSSZES KÖLTÉS</span><b>€624</b></div><div class="mini-stat"><span>ÁTLAG CIKLUS</span><b>25 nap</b></div><div class="mini-stat"><span>NO-SHOW</span><b>0</b></div></div><section class="cut-memory"><div class="cut-head"><div><span>✦ CUT MEMORY · AI ÖSSZEFOGLALÓ</span><h3>Leon bevált vágása</h3></div><span>Frissítve aug. 28.</span></div><div class="cut-specs"><div><small>OLDAL</small><b>0 → 1.5 skin fade</b></div><div><small>TETŐ</small><b>5 cm, texturált</b></div><div><small>ÁTMENET</small><b>Low–mid, lágy</b></div><div><small>SZAKÁLL</small><b>6 mm, éles vonal</b></div><div><small>TERMÉK</small><b>Matte Clay</b></div><div><small>MEGJEGYZÉS</small><b>Bal forgót hagyni</b></div></div></section><div class="timeline"><h3>Látogatási idővonal</h3><div class="visit"><b>aug. 28.</b><span><b>Skin Fade + Beard · Dani</b><small>5★ · Matte Clay vásárlás</small></span><b>€64</b></div><div class="visit"><b>aug. 02.</b><span><b>Skin Fade · Dani</b><small>Cut Memory frissítve</small></span><b>€42</b></div></div></div></section></div>',
  staff: () =>
    '<div class="section-bar"><div><h2>Csapat és teljesítmény</h2><small class="muted">Műszakok, jogosultságok, jutalékok és célok</small></div><button class="primary small" data-action="add-staff">+ Munkatárs</button></div><table class="table"><thead><tr><th>BARBER</th><th>MA</th><th>KIHASZNÁLTSÁG</th><th>30 NAP BEVÉTEL</th><th>VISSZAFOGLALÁS</th><th>ÉRTÉKELÉS</th></tr></thead><tbody><tr><td><b>Dani Szabó</b><br><span class="muted">Fade specialist</span></td><td>7 vendég</td><td><span class="badge">91%</span></td><td>€5,840</td><td>78%</td><td>4,9 ★</td></tr><tr><td><b>Marco Klein</b><br><span class="muted">Senior barber</span></td><td>6 vendég</td><td><span class="badge">84%</span></td><td>€5,260</td><td>74%</td><td>4,9 ★</td></tr><tr><td><b>Alex Roth</b><br><span class="muted">Barber & stylist</span></td><td>4 vendég</td><td><span class="badge blue">72%</span></td><td>€4,110</td><td>66%</td><td>4,8 ★</td></tr></tbody></table><div class="content-grid"><section class="panel"><div class="panel-head"><h2>AI Performance Coach</h2><span class="badge blue">HETI</span></div><p>Dani erőssége a fade-vendégek megtartása. Alexnél a szék melletti újrafoglalás 11%-kal az üzleti átlag alatt van.</p><button class="primary small" data-action="coach">Személyes coaching terv</button></section><section class="panel"><div class="panel-head"><h2>Következő műszakok</h2></div><div class="walkin"><span><b>Szerda</b><small>10:00–20:00</small></span><b>3 barber</b></div><div class="walkin"><span><b>Csütörtök</b><small>10:00–20:00</small></span><b>3 barber</b></div></section></div>',
  money: () =>
    '<div class="section-bar"><div><h2>Checkout · Leon Müller</h2><small class="muted">Skin Fade + Beard · Dani · 16:15</small></div><div class="filters"><button>Napi zárás</button><button>Tranzakciók</button><button>Riportok</button></div></div><div class="checkout"><section class="receipt"><h2>Tételek</h2><div class="line-item"><span><b>Skin Fade + Beard</b><small class="muted">60 perc · Dani</small></span><b>€52</b></div><div class="line-item addon-line hidden"><span><b>NOIR Matte Clay</b><small class="muted">AI ajánlás · 100 ml</small></span><b>€18</b></div><div class="addon"><span><b>✦ Smart add-on</b><br><small class="muted">Leon az előző alkalommal Matte Clay-t vett.</small></span><button data-action="add-product">+ €18</button></div><div class="total-line"><span>Összesen</span><b id="checkoutTotal">€52</b></div></section><aside class="pay-panel"><h2>Fizetés</h2><small class="muted">Borravaló</small><div class="tip-row"><button class="active" data-tip="0">Nincs</button><button data-tip="5">5%</button><button data-tip="10">10%</button><button data-tip="15">15%</button></div><div class="payment-methods"><button class="active">◉ Tap to Pay</button><button>▣ Készpénz</button><button>↗ Fizetési link</button><button>◇ Ajándékkártya</button></div><button class="pay-now" data-action="pay">Fizetés · <span id="payAmount">€52</span></button><p class="muted" style="font-size:.68rem">Nyugta, jutalék és készlet automatikusan frissül.</p></aside></div>',
  grow: () =>
    '<div class="section-bar"><div><h2>Growth Center</h2><small class="muted">Szegmensek, automatizmusok, kampányok és értékelések</small></div><button class="primary small" data-action="new-campaign">+ Kampány</button></div><div class="campaign-grid"><article class="campaign"><span class="tag">✦ AI REACTIVATION</span><h3>9 at-risk vendég</h3><p>6–10 hete nem tértek vissza, pedig korábbi ciklusuk szerint esedékesek.</p><span class="estimate">+€286</span><small>becsült bevétel</small><button data-action="campaign">Kampány előkészítése</button></article><article class="campaign"><span class="tag">EMPTY CHAIR</span><h3>Dani · ma 15:30</h3><p>6 várólistás vendég közül Felix 96%-os illeszkedést kapott.</p><span class="estimate">+€42</span><small>helyreállítható</small><button data-action="fill-gap">Meghívás kiküldése</button></article><article class="campaign"><span class="tag">REVIEWS</span><h3>14 értékelés kérhető</h3><p>Boldog, visszatérő vendégek személyre szabott review linkkel.</p><span class="estimate">4.9 ★</span><small>jelenlegi átlag</small><button data-action="reviews">Review flow indítása</button></article></div><div class="content-grid"><section class="panel"><div class="panel-head"><h2>Aktív automatizmusok</h2><button>Összes</button></div><table class="table"><tr><td><b>25 napos rebook emlékeztető</b></td><td><span class="badge">AKTÍV</span></td><td>€724 / 30 nap</td></tr><tr><td><b>No-show megerősítés</b></td><td><span class="badge">AKTÍV</span></td><td>€312 védett</td></tr><tr><td><b>Születésnapi ajánlat</b></td><td><span class="badge">AKTÍV</span></td><td>18 foglalás</td></tr></table></section><section class="panel"><div class="panel-head"><h2>Csatornák</h2></div><div class="walkin"><span><b>SMS</b><small>98,7% kézbesítés</small></span><span class="badge">AKTÍV</span></div><div class="walkin"><span><b>WhatsApp</b><small>Human handoff engedélyezve</small></span><span class="badge">AKTÍV</span></div><div class="walkin"><span><b>Email</b><small>Branded template</small></span><span class="badge">AKTÍV</span></div></section></div>',
  inventory: () =>
    '<div class="section-bar"><div><h2>Készlet és termékek</h2><small class="muted">48 termék · 2 újrarendelési jelzés</small></div><button class="primary small" data-action="stock-order">Új rendelés</button></div><table class="table"><thead><tr><th>TERMÉK</th><th>KÉSZLET</th><th>ELADÁS / 30D</th><th>ÁRRÉS</th><th>ELŐREJELZÉS</th><th></th></tr></thead><tbody><tr><td><b>NOIR Matte Clay</b></td><td>18 db</td><td>24 db</td><td>61%</td><td><span class="badge">21 nap</span></td><td><button class="ghost">Részletek</button></td></tr><tr><td><b>Beard Oil Cedar</b></td><td>5 db</td><td>13 db</td><td>58%</td><td><span class="badge red">8 nap</span></td><td><button class="ghost" data-action="reorder">Újrarendelés</button></td></tr><tr><td><b>Sea Salt Spray</b></td><td>7 db</td><td>11 db</td><td>54%</td><td><span class="badge red">12 nap</span></td><td><button class="ghost" data-action="reorder">Újrarendelés</button></td></tr></tbody></table><div class="content-grid"><section class="panel"><div class="panel-head"><h2>AI készlet-előrejelzés</h2><span class="badge blue">FORECAST</span></div><p>A Beard Oil Cedar készlete a következő nagykereskedelmi szállítás előtt elfogyhat. Javasolt rendelés: 18 db.</p><button class="primary small" data-action="reorder">Rendeléstervezet létrehozása</button></section><section class="panel"><div class="panel-head"><h2>Retail teljesítmény</h2></div><b style="font-size:1.8rem">€1,842</b><p class="muted">Termékbevétel / 30 nap · +14%</p></section></div>',
  ai: () =>
    '<div class="section-bar"><div><h2>AI Manager</h2><small class="muted">Barber-specifikus intelligencia, tulajdonosi kontrollal</small></div><div class="filters"><button class="active">Ajánlások</button><button>Automatizmusok</button><button>Guardrails</button></div></div><div class="ai-grid"><article class="ai-action featured"><span class="tag">01 · EMPTY CHAIR RECOVERY</span><h3>Töltsd fel Dani 15:30-as helyét</h3><p>Felix 96%-os match, elérhető és 23 napja járt utoljára.</p><span class="estimate">+€42</span><button data-action="fill-gap">Jóváhagyás és küldés</button></article><article class="ai-action"><span class="tag">02 · HAIRCUT CYCLE</span><h3>14 vendég ma esedékes</h3><p>Személyes rebook időzítés a tényleges vágási ciklus alapján.</p><span class="estimate">+€286</span><button data-action="campaign">Üzenetek ellenőrzése</button></article><article class="ai-action"><span class="tag">03 · NO-SHOW RISK</span><h3>2 foglalás megerősítendő</h3><p>Magyarázható kockázati jelzés; csak egyiknél javasolt pre-auth.</p><span class="estimate">€104 védett</span><button data-action="risk">Kockázatok megnyitása</button></article><article class="ai-action"><span class="tag">04 · BARBER MATCH</span><h3>Új vendégek jobb párosítása</h3><p>Stílus, hajtípus, portfólió, értékelés és szabad kapacitás alapján.</p><span class="estimate">98% top match</span><button data-action="match">Logika megtekintése</button></article><article class="ai-action"><span class="tag">05 · CONTENT STUDIO</span><h3>8 before/after poszt kész</h3><p>Vendéghozzájárulás ellenőrizve, barber-brand hangnem beállítva.</p><span class="estimate">8 draft</span><button data-action="content">Tartalmak megnyitása</button></article><article class="ai-action"><span class="tag">06 · MARGIN COACH</span><h3>Cut + Beard ára alacsony</h3><p>Idő- és költségadat alapján €3–5 emelés modellezhető.</p><span class="estimate">+€410 / hó</span><button data-action="pricing">Ármodell futtatása</button></article></div><div class="feature-matrix"><details open><summary>Mind a 22 barber-specifikus AI képesség</summary><p>Haircut Cycle Predictor · Empty Chair Recovery · No-show Risk Engine · Barber Match AI · Cut Memory · Visual Consultation · Walk-in Queue Optimiser · Smart Gap Compression · Demand & Capacity Forecast · AI Daily Brief · Client Churn Predictor · Personalised Reactivation · Revenue Attribution · AI Review Assistant · Before/After Content Studio · Price & Margin Coach · Smart Add-on Coach · Barber Performance Coach · Inventory Forecast · Conversational OS Command · AI Revenue Guardrails · Multilingual Concierge</p></details></div>',
  impact: () =>
    '<section class="impact-hero"><div><small>OPERATOR ATTRIBUTED VALUE · 30 DAYS</small><h2>' +
    money(state.impact) +
    " <span>estimated</span></h2></div></section>",
  settings: () =>
    '<div class="section-bar"><div><h2>Beállítások és integrációk</h2><small class="muted">Minden konkurens-alapfunkció megtalálható a V2 demóban</small></div><button class="primary small" data-action="save-settings">Mentés</button></div><div class="settings-grid"><article class="setting-card"><div class="toggle"></div><h3>Online foglalás</h3><p>White-label oldal, widget, direct link, QR, social és Reserve with Google.</p></article><article class="setting-card"><div class="toggle"></div><h3>Fizetés és védelem</h3><p>Deposit, prepayment, card on file, pre-auth, cancellation fee, Tap to Pay.</p></article><article class="setting-card"><div class="toggle"></div><h3>Kommunikáció</h3><p>SMS, WhatsApp, email, push, kétirányú inbox és többnyelvű sablonok.</p></article><article class="setting-card"><div class="toggle"></div><h3>Szolgáltatások</h3><p>Variánsok, combo, add-on, buffer, erőforrások, egyedi ár és barber szint.</p></article><article class="setting-card"><div class="toggle"></div><h3>Adat és jogosultságok</h3><p>GDPR, export, szerepkörök, audit log, hozzájárulások és adatmegőrzés.</p></article><article class="setting-card"><div class="toggle"></div><h3>Integrációk</h3><p>Google Calendar, Meta, Google Business, könyvelés, API és webhookok.</p></article></div><div class="feature-matrix"><details open><summary>Foglalás & naptár</summary><p>24/7 foglalás · real-time availability · barber/first available · lead time · cancel/reschedule · drag-and-drop · break/time off · multiple locations · waitlist · combo/add-on/variant · buffer · resource · walk-in queue</p></details><details><summary>CRM & védelem</summary><p>Profilok · előzmények · jegyzetek · fotók · formok · aláírás · tagek · VIP/blokkolás · wallet · inbox · reminder · deposit · prepayment · cancellation/no-show fee · risk-based pre-auth</p></details><details><summary>POS, marketing és működés</summary><p>POS · készpénz/kártya · Tap to Pay · terminál · tip · refund · receipt/VAT · gift card · package · membership · campaigns · segmentáció · loyalty · reviews · analytics · staff · payroll/commission · inventory · multi-location</p></details></div>',
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
modules.operator = () =>
  '<div class="operator-score"><div><span>REVENUE TARGET</span><b>' +
  money(state.target) +
  "</b></div><div><span>CURRENT FORECAST</span><b>" +
  money(state.forecast) +
  '</b></div><div><span>PROJECTED GAP</span><b class="' +
  (state.gap > 0 ? "negative" : "positive") +
  '">' +
  (state.gap > 0 ? "−" + money(state.gap) : "+" + money(Math.abs(state.gap))) +
  '</b></div><div><span>MODE</span><b>COPILOT</b></div></div><section class="operator-analysis"><header><div><span>✦ OPERATOR ANALYSIS</span><h2>' +
  (state.plan === "active"
    ? "Approved plan is running"
    : "Revenue goal is at risk") +
  '</h2></div><span class="demo-chip">DEMO DATA</span></header><div class="signals"><div><b>18</b><span>empty appointments</span></div><div><b>47</b><span>customers due to return</span></div><div><b>12</b><span>high-value customers at churn risk</span></div><div><b>61%</b><span>Tue–Thu utilization</span></div></div></section><section class="plan-card"><div class="plan-head"><div><span>PREPARED PLAN · 5 ACTIONS</span><h2>Close the monthly revenue gap</h2><p>Optimized for revenue, margin, retention and your current approval rules.</p></div><div class="plan-total"><span>TOTAL EXPECTED IMPACT</span><b>+€1,500</b></div></div><div class="plan-lines"><div><span><b>Customer reactivation</b><small>12 high-value customers · personalized</small></span><strong>+€540</strong></div><div><span><b>Cancellation / waitlist recovery</b><small>8 best-fit offers · no discount</small></span><strong>+€280</strong></div><div><span><b>Personalized rebooking</b><small>47 cycle-aware messages</small></span><strong>+€390</strong></div><div><span><b>Marketing optimization</b><small>Move €47 budget to higher-performing segment</small></span><strong>+€120</strong></div><div><span><b>Upsell opportunities</b><small>Contextual product and service suggestions</small></span><strong>+€170</strong></div></div><div class="plan-meta"><span><small>ESTIMATED COST</small><b>€47</b></span><span><small>CONFIDENCE</small><b>78%</b></span><span><small>RISK</small><b>Low</b></span><span><small>OWNER DECISIONS</small><b>1</b></span></div><div class="plan-actions">' +
  (state.plan === "active"
    ? '<button class="primary" data-action="view-results">VIEW RESULTS</button>'
    : '<button class="primary" data-action="approve-plan">APPROVE PLAN</button><button class="secondary" data-action="modify-plan">Modify</button><button class="secondary" data-action="reject-plan">Reject</button><button class="text-btn" data-action="reasoning">Show reasoning</button>') +
  "</div></section>";
modules.live = () =>
  '<div class="live-strip"><div><span>LIVE BUSINESS</span><b>3 staff · ' +
  (state.plan === "active" ? "22" : "17") +
  ' appointments</b></div><span class="live-now"><i></i> Updated now</span></div><div class="staff-live"><article><header><span class="avatar lime">SA</span><div><b>Sarah</b><small>BUSY · ends 14:45</small></div></header><div class="seat-progress"><i style="width:82%"></i></div><p>Utilization 92% · next 15:00</p></article><article><header><span class="avatar dark">MK</span><div><b>Marco</b><small>AVAILABLE · next 15:30</small></div></header><div class="seat-progress"><i style="width:61%"></i></div><p>Capacity for +€2,100 / month</p></article><article class="' +
  (state.liveSlotFilled ? "" : "attention") +
  '"><header><span class="avatar sand">DS</span><div><b>Daniel</b><small>' +
  (state.liveSlotFilled
    ? "BOOKED · Anna at 14:30"
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
  '<div class="memory-hero"><span>BUSINESS MEMORY</span><h2>The Operator improves strategy from outcomes, not assumptions.</h2><p>Only observed business results are promoted into memory.</p></div><div class="memory-grid"><article><span>REBOOKING</span><h3>Personalized rebooking performs 2.3× better than discounts.</h3><small>Based on 184 completed outreach actions</small></article><article><span>CAPACITY</span><h3>Thursday 13:00–16:00 consistently underperforms.</h3><small>Observed across 14 weeks</small></article><article><span>CUSTOMER CYCLE</span><h3>Marco’s customers return every 26.4 days on average.</h3><small>Confidence 91%</small></article><article><span>MARGIN</span><h3>Saturday discounts reduce margin without meaningful growth.</h3><small>Strategy guardrail updated</small></article><article><span>REVIEWS</span><h3>Review requests within two hours perform 34% better.</h3><small>Based on 312 completed visits</small></article>' +
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
        "Eva booked with Marco",
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
        "Anna booked · €45 recovered",
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
  '<div class="section-bar"><div><h2>Customer Intelligence</h2><small class="muted">1,284 profiles · decisions, not database administration</small></div><span class="demo-chip">DEMO DATA</span></div><div class="customer-layout"><section class="customer-list"><div class="list-search"><input placeholder="Search customer…"></div><div class="client-row active"><span class="avatar dark">LM</span><div><b>Leon Müller</b><small>VIP · LTV €1,840</small></div></div><div class="client-row"><span class="avatar lime">MF</span><div><b>Max Fischer</b><small>' +
  (state.plan === "active"
    ? "REACTIVATED · booked"
    : "LIKELY OVERDUE · 71% AI chance") +
  '</small></div></div><div class="client-row"><span class="avatar sand">PN</span><div><b>Paul Novak</b><small>Churn risk · high value</small></div></div></section><section class="customer-profile"><div class="profile-top"><div class="profile-name"><span class="avatar dark">LM</span><div><h2>Leon Müller</h2><p>VIP · preferred employee: Dani · preferred time: 16:00–18:00</p></div></div><div class="profile-actions"><button class="primary small" data-action="reactivate">REACTIVATE</button></div></div><div class="profile-body"><div class="profile-stats"><div class="mini-stat"><span>LIFETIME VALUE</span><b>€1,840</b></div><div class="mini-stat"><span>VISITS</span><b>28</b></div><div class="mini-stat"><span>AVERAGE SPEND</span><b>€65.70</b></div><div class="mini-stat"><span>TYPICAL CYCLE</span><b>25 days</b></div><div class="mini-stat"><span>LAST VISIT</span><b>28 Aug</b></div><div class="mini-stat"><span>NO-SHOWS</span><b>0</b></div><div class="mini-stat"><span>LOYALTY</span><b>840 pts</b></div><div class="mini-stat"><span>MEMBERSHIP</span><b>NOIR Plus</b></div></div><section class="customer-ai"><span>✦ AI STATUS · LIKELY OVERDUE</span><div><p>Return probability without action</p><b>34%</b></div><div><p>Personalized rebooking probability</p><b>71%</b></div><p>Predicted next visit: September 24–29 · recommended channel: WhatsApp · no discount.</p></section><div class="customer-tabs"><span>Booking history</span><span>Payment history</span><span>Notes & preferences</span><span>Photos</span><span>Communication</span></div><section class="cut-memory"><div class="cut-head"><div><span>CUT MEMORY</span><h3>0 → 1.5 low–mid fade · 5 cm textured top</h3></div><span>Updated Aug 28</span></div></section></div></section></div>';
modules.staff = () =>
  '<div class="section-bar"><div><h2>Staff Intelligence</h2><small class="muted">Capacity and economics · no vanity ranking</small></div><span class="demo-chip">DEMO DATA</span></div><div class="staff-cards"><article><header><span class="avatar lime">SA</span><div><h3>Sarah</h3><p>Senior barber</p></div></header><div class="staff-metrics"><span>Revenue <b>€8,420</b></span><span>Utilization <b>94%</b></span><span>Retention <b>82%</b></span><span>Avg. ticket <b>€58</b></span><span>Hours <b>168</b></span><span>Payout est. <b>€3,940</b></span></div><div class="staff-insight"><b>✦ Capacity insight</b><p>Sarah is approaching capacity. Additional marketing is unlikely to produce meaningful growth.</p><button data-action="staff-plan">CREATE GROWTH PLAN</button></div></article><article><header><span class="avatar dark">MK</span><div><h3>Marco</h3><p>Barber & stylist</p></div></header><div class="staff-metrics"><span>Revenue <b>€5,260</b></span><span>Utilization <b>68%</b></span><span>Retention <b>74%</b></span><span>Avg. ticket <b>€49</b></span><span>Hours <b>160</b></span><span>Payout est. <b>€2,710</b></span></div><div class="staff-insight opportunity-insight"><b>✦ Growth capacity</b><p>Marco has capacity for approximately €2,100 additional monthly revenue.</p><button data-action="staff-plan">CREATE GROWTH PLAN</button></div></article></div><section class="core-links"><span>Schedule</span><span>Roles & permissions</span><span>Commission</span><span>Tips</span><span>Holidays</span><span>Working hours</span><span>Services</span><span>Customers</span></section>';
modules.calendar = () =>
  '<div class="section-bar"><div><h2>Calendar · September 22</h2><small class="muted">3 staff · ' +
  (state.plan === "active" ? "79%" : "74%") +
  " utilization · " +
  (state.plan === "active" ? "5 Operator bookings added" : "8 empty slots") +
  '</small></div><div class="filters"><button class="active">Day</button><button>Week</button><button>Locations</button><button data-action="manual-booking">+ Manual booking</button></div></div>' +
  (state.manualBooking
    ? '<section class="state-change-banner"><b>Manual booking added · Eva · Classic Cut · 18:00</b><span>+€42 forecast · shared demo state</span></section>'
    : "") +
  (state.recurringCreated
    ? '<section class="state-change-banner"><b>Recurring series created · Leon · 4 visits</b><span>+€168 forecast · next 4 cycles reserved</span></section>'
    : "") +
  (state.plan === "active"
    ? '<section class="state-change-banner"><b>✓ OPERATOR PLAN APPLIED</b><span>5 new bookings added · forecast +€1,500 · traceable in Impact</span></section>'
    : "") +
  '<div class="calendar-board">' +
  calendar() +
  "</div>" +
  (state.plan === "active"
    ? '<section class="new-bookings"><h3>New bookings from approved plan</h3><div><span>Max F. · Rebooking</span><b>Wed 17:00 · €42</b></div><div><span>Paul N. · Reactivation</span><b>Thu 15:30 · €52</b></div><div><span>Anna K. · Waitlist recovery</span><b>Today 14:30 · €45</b></div></section>'
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
  let t = titles[id];
  $("#pageTitle").textContent = t[0];
  $("#pageSub").textContent = t[1];
  $("#moduleContent").innerHTML = modules[id]();
  $$("[data-module]").forEach((b) =>
    b.classList.toggle("active", b.dataset.module === id),
  );
  bind();
  window.scrollTo({ top: 0, behavior: "smooth" });
}
$$("[data-module]").forEach(
  (b) => (b.onclick = () => renderModule(b.dataset.module)),
);
function bind() {
  $$("[data-go]").forEach(
    (b) => (b.onclick = () => renderModule(b.dataset.go)),
  );
  $$("[data-action]").forEach(
    (b) => (b.onclick = () => act(b.dataset.action, b)),
  );
  $$("[data-core-tab]").forEach(
    (b) =>
      (b.onclick = () => {
        state.coreTab = b.dataset.coreTab;
        renderModule("core");
      }),
  );
  $$("[data-sim]").forEach(
    (b) =>
      (b.onclick = () => {
        $("#simulationResult").innerHTML = simulation(b.dataset.sim);
        $$("[data-sim]").forEach((x) => x.classList.toggle("active", x === b));
      }),
  );
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
    '<span class="drawer-kicker">FOGLALÁS · MA 16:15</span><h2>Leon Müller</h2><p class="muted">Skin Fade + Beard · Dani · 60 perc</p><div class="drawer-section"><div class="detail-grid"><div><small>STÁTUSZ</small><b>✓ Megerősítve</b></div><div><small>FIZETÉS</small><b>€52 helyszínen</b></div><div><small>KOCKÁZAT</small><b>Alacsony · 4%</b></div><div><small>CIKLUS</small><b>25. nap · pontos</b></div></div></div><div class="drawer-section"><h3>✦ Cut Memory</h3><p>0 → 1.5 low–mid fade · 5 cm texturált tető · 6 mm szakáll · Matte Clay · bal forgót hagyni.</p></div><div class="drawer-section"><h3>Vendégelőzmény</h3><p>12 látogatás · €624 költés · 0 no-show · 4,9 ★ átlagos értékelés</p></div><div class="drawer-actions"><button class="confirm" data-action="open-checkout">Checkout megnyitása</button><button data-action="message-client">Üzenet</button><button data-action="reschedule">Áthelyezés</button><button class="danger" data-action="cancel-booking">Lemondás</button></div>',
  );
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
  $("#moduleContent").innerHTML =
    '<section class="plan-activated"><div class="activation-check">✓</div><span>PLAN ACTIVATED</span><h2>Revenue goal is back on track.</h2><p>The Operator updated capacity, customer outreach and forecast across the system.</p><div class="activation-metrics"><div><small>FORECAST</small><b>€23,680 → €25,180</b></div><div><small>NEW BOOKINGS</small><b>+5</b></div><div><small>EXPECTED IMPACT</small><b>+€1,500</b></div></div><div class="plan-actions"><button class="primary" data-go="calendar">VIEW UPDATED CALENDAR</button><button class="secondary" data-go="impact">VIEW IMPACT</button><button class="secondary" data-go="decisions">DECISION LOG</button></div></section>';
  bind();
}
function act(a, e) {
  if (a === "manual-booking")
    return openDrawer(
      '<span class="drawer-kicker">MANUAL CONTROL · WORKING DEMO</span><h2>Create appointment</h2><p class="muted">The Operator can do this from a goal, but full manual control remains available.</p><div class="drawer-section"><div class="detail-grid"><div><small>CUSTOMER</small><b>Eva Bauer</b></div><div><small>SERVICE</small><b>Classic Cut · €42</b></div><div><small>STAFF</small><b>Marco</b></div><div><small>TIME</small><b>Today · 18:00</b></div></div></div><button class="primary" data-action="confirm-manual">CREATE BOOKING</button>',
    );
  if (a === "confirm-manual") {
    Object.assign(state, {
      manualBooking: true,
      appointments: state.appointments + 1,
      forecast: state.forecast + 42,
      gap: state.gap - 42,
    });
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
    renderModule("core");
    return toast("Group booking reserved", "3 customers · 2 resources · +€156");
  }
  if (a === "core-form") {
    state.formSent = true;
    renderModule("core");
    return toast(
      "Consultation completed",
      "Signed consent attached to customer timeline",
    );
  }
  if (a === "core-refund") {
    state.refundPending = true;
    renderModule("core");
    return toast(
      "Decision required",
      "€42 refund is outside automatic permissions",
    );
  }
  if (a === "core-purchase") {
    state.poPrepared = true;
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
    return toast("Loyalty updated", "Visit completed · +50 points");
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
  if (a === "approve-plan") return startExecution();
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
    state.plan = "rejected";
    return toast(
      "Plan rejected",
      "No actions were executed. Reason saved for learning.",
    );
  }
  if (a === "fill-live-slot") {
    state.liveSlotFilled = true;
    state.forecast += 45;
    state.impact += 45;
    state.filled++;
    return renderModule("live");
  }
  if (a === "impact-detail")
    return openDrawer(
      '<span class="drawer-kicker">ATTRIBUTION TRAIL · DEMO DATA</span><h2>Cycle-aware reactivation</h2><p class="muted">Every outcome links to the approved action and resulting booking.</p><div class="drawer-section"><div class="attribution-mini"><span>Max F. · WhatsApp rebook</span><b>€42</b></div><div class="attribution-mini"><span>Paul N. · SMS reactivation</span><b>€52</b></div><div class="attribution-mini"><span>Leon M. · membership return</span><b>€64</b></div></div><div class="detail-grid"><div><small>COST</small><b>€18</b></div><div><small>ATTRIBUTED</small><b>€540</b></div></div>',
    );
  if (a === "diagnose-location")
    return openDrawer(
      '<span class="drawer-kicker">VIENNA WEST DIAGNOSIS</span><h2>Retention, not demand, is the constraint.</h2><p>Rebooking is 14 points below network average. Marco has €2,100 monthly spare capacity.</p><div class="drawer-section"><h3>Prepared plan</h3><p>Cycle-aware rebooking · staff coaching · Thursday capacity campaign. No price change.</p></div><button class="primary" data-action="save-modified">PREPARE FOR APPROVAL</button>',
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
    state.impact += 42;
    toast("Empty slot filled", "Felix accepted the 15:30 appointment · +€42");
    if (state.module === "impact") renderModule("impact");
    return;
  }
  if (a === "run-brief") return renderModule("operator");
  if (a === "campaign") return renderModule("operator");
  if (a === "send-campaign") {
    closeDrawer();
    return toast("Campaign started", "14 personalized messages · approved");
  }
  if (a === "risk")
    return openDrawer(
      '<span class="drawer-kicker">NO-SHOW RISK ENGINE</span><h2>2 bookings need review</h2><p class="muted">Explainable risk; no automatic punishment.</p><div class="drawer-section"><h3>Leo · 14:30 · 68% risk</h3><p>2 late cancellations · new phone number · peak 60-minute service.</p><button class="primary small" data-action="preauth">Request €52 pre-auth</button></div>',
    );
  if (a === "preauth") {
    closeDrawer();
    return toast("Pre-auth sent", "Leo has 30 minutes to confirm");
  }
  if (a === "add-product") {
    state.addon = 18;
    $(".addon-line").classList.remove("hidden");
    e.disabled = true;
    e.textContent = "Added";
    return checkout();
  }
  if (a === "pay")
    return toast(
      "Payment complete",
      $("#payAmount").textContent + " · Tap to Pay · receipt sent",
    );
  if (a === "message-client")
    return toast("Message prepared", "WhatsApp · owner approval not required");
  if (a === "invite-waitlist")
    return toast("Invite sent", "Slot reserved for Felix for 15 minutes");
  if (a === "reorder")
    return toast("Purchase order prepared", "Approval required above €50");
  if (a === "reviews")
    return toast("Review flow active", "14 requests scheduled");
  if (a === "save-settings")
    return toast("Settings saved", "Rules and channels synchronized");
  if (a === "master-apply")
    return toast(
      "Network playbook prepared",
      "Approval queued for 42 businesses",
    );
  toast("Demo action complete", e?.textContent.trim() || "Updated");
}
function checkout() {
  let s = 52 + state.addon,
    t = s * (1 + state.tip / 100);
  if ($("#checkoutTotal")) $("#checkoutTotal").textContent = money(s);
  if ($("#payAmount")) $("#payAmount").textContent = money(t);
}
function bookRefresh() {
  $$(".book-step").forEach((s, i) =>
    s.classList.toggle("hidden", i !== state.bookStep - 1),
  );
  $$(".stepper span").forEach((s, i) =>
    s.classList.toggle("active", i < state.bookStep),
  );
  $("#bookBack").disabled = state.bookStep === 1;
  let ok = [
    state.service,
    state.barber,
    state.time,
    $("#guestName").value.trim() && $("#guestPhone").value.trim(),
  ][state.bookStep - 1];
  $("#bookNext").disabled = !ok;
  $("#bookNext").textContent =
    state.bookStep === 4 ? "Kostenpflichtig buchen" : "Weiter";
}
$$("[data-service]").forEach(
  (b) =>
    (b.onclick = () => {
      $$("[data-service]").forEach((x) => x.classList.remove("selected"));
      b.classList.add("selected");
      state.service = b.dataset.service;
      state.price = +b.dataset.price;
      $("#sumService").textContent = state.service;
      $("#sumPrice").textContent = money(state.price);
      bookRefresh();
    }),
);
$$("[data-barber]").forEach(
  (b) =>
    (b.onclick = () => {
      $$("[data-barber]").forEach((x) => x.classList.remove("selected"));
      b.classList.add("selected");
      state.barber = b.dataset.barber;
      $("#sumBarber").textContent = state.barber;
      bookRefresh();
    }),
);
$$("[data-time]").forEach(
  (b) =>
    (b.onclick = () => {
      $$("[data-time]").forEach((x) => x.classList.remove("selected"));
      b.classList.add("selected");
      state.time = b.dataset.time;
      $("#sumTime").textContent = "Di, 22. Sep · " + state.time;
      bookRefresh();
    }),
);
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
$("#bookNext").onclick = () => {
  if (state.bookStep < 4) {
    state.bookStep++;
    bookRefresh();
  } else {
    $$(".book-step").forEach((x) => x.classList.add("hidden"));
    $("#bookActions").classList.add("hidden");
    $("#bookingSuccess").classList.remove("hidden");
    toast(
      "Foglalás bekerült a HQ-ba",
      "SMS megerősítés és Cut Memory profil létrehozva",
    );
  }
};
["guestName", "guestPhone"].forEach(
  (id) => ($("#" + id).oninput = bookRefresh),
);
$('[data-action="repeat-cut"]').onclick = () => {
  state.service = "Skin Fade";
  state.price = 42;
  state.barber = "Dani";
  state.time = "16:15";
  $("#sumService").textContent = "Skin Fade";
  $("#sumBarber").textContent = "Dani";
  $("#sumTime").textContent = "Di, 22. Sep · 16:15";
  $("#sumPrice").textContent = "€42";
  state.bookStep = 4;
  bookRefresh();
  toast(
    "Cut Memory betöltve",
    "A legutóbbi vágás, barber és preferenciák készen állnak",
  );
};
$('[data-action="waitlist"]').onclick = () =>
  toast(
    "Várólista aktiválva",
    "SMS-t kapsz, ha megfelelő időpont szabadul fel",
  );
$('[data-action="new-booking"]').onclick = () => location.reload();
bind();
renderModule("home");
bookRefresh();
