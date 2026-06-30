const app = document.getElementById("app");
const upgradeList = document.getElementById("upgrade-list");
const reportBtn = document.getElementById("report-btn");

window.addEventListener("message", (event) => {
  const { action, data } = event.data;

  if (action === "open") {
    populateUI(data);
    document.body.classList.add("active");
    app.classList.add("show");
  }

  if (action === "close") {
    app.classList.remove("show");
    setTimeout(() => {
      document.body.classList.remove("active");
    }, 400);
  }
});

const populateUI = (data) => {
  // Main Info
  document.getElementById("spawncode").textContent = data.spawncode;
  document.getElementById("modelhash").textContent = `HASH: 0x${data.modelHash.toString(16).toUpperCase()}`;
  document.getElementById("baseline-speed").textContent = `${data.baselineSpeed} MPH`;
  document.getElementById("upgraded-speed").textContent = `${data.upgradedSpeed} MPH`;
  document.getElementById("acceleration").textContent = data.acceleration;
  document.getElementById("gears").textContent = data.gears;
  document.getElementById("capacity").textContent = data.capacity;

  // Upgrades
  upgradeList.innerHTML = "";
  
  const performanceMods = [
    { type: 11, name: "Engine" },
    { type: 12, name: "Brakes" },
    { type: 13, name: "Transmission" },
    { type: 15, name: "Suspension" },
    { type: 16, name: "Armor" },
  ];

  performanceMods.forEach(mod => {
    const modData = data.currentMods[mod.type];
    const li = document.createElement("li");
    li.className = "flex items-center gap-3 text-slate-300";
    
    let statusText = "N/A";
    if (modData) {
        const level = modData.current === 0 ? "Stock" : `Level ${modData.current}`;
        statusText = `${level} (Stock - Level ${modData.levels})`;
    }
    
    li.innerHTML = `
      <span class="w-1.5 h-1.5 rounded-full bg-slate-400"></span>
      <span class="text-sm font-medium">${mod.name}: <span class="text-white font-semibold">${statusText}</span></span>
    `;
    upgradeList.appendChild(li);
  });

  // Turbo separately
  const turboData = data.currentMods[18];
  const turboLi = document.createElement("li");
  turboLi.className = "flex items-center gap-3 text-slate-300";
  const hasTurbo = turboData && turboData.current > 0;
  
  turboLi.innerHTML = `
    <span class="w-1.5 h-1.5 rounded-full bg-slate-400"></span>
    <span class="text-sm font-medium">Turbo: 
        ${hasTurbo ? '<i class="fa-solid fa-check text-green-400 ml-1"></i> <span class="text-white font-semibold">Installed</span>' : '<i class="fa-solid fa-xmark text-red-400 ml-1"></i> <span class="text-white font-semibold">Stock - Level 1</span>'}
    </span>
  `;
  upgradeList.appendChild(turboLi);
};

reportBtn.addEventListener("click", () => {
  fetch(`https://${GetParentResourceName()}/reportToDiscord`, {
    method: "POST",
    body: JSON.stringify({}),
  });
});

const closeUI = () => {
  fetch(`https://${GetParentResourceName()}/close`, {
    method: "POST",
    body: JSON.stringify({}),
  });
};

document.addEventListener("keydown", (e) => {
  if (e.key === "Escape") {
    closeUI();
  }
});