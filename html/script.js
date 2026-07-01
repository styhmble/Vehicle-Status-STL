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

  // Upgrades - dynamically show all available mods
  upgradeList.innerHTML = "";
  
  const modTypeNames = {
    0: "Spoiler",
    1: "Front Bumper",
    2: "Rear Bumper",
    3: "Side Skirt",
    4: "Exhaust",
    5: "Roll Cage",
    6: "Grille",
    7: "Hood",
    8: "Fenders",
    9: "Roof",
    10: "Vanity Plates",
    11: "Engine",
    12: "Brakes",
    13: "Transmission",
    14: "Tires",
    15: "Suspension",
    16: "Armor",
    17: "Xenon Lights",
    18: "Turbo",
    22: "Horn",
    23: "Hydraulics",
  };

  const hasMods = Object.keys(data.currentMods).length > 0;
  
  if (!hasMods) {
    upgradeList.innerHTML = '<li class="text-slate-400 text-sm">No upgrades available</li>';
  } else {
    Object.entries(data.currentMods).forEach(([type, modData]) => {
      const li = document.createElement("li");
      li.className = "flex items-center gap-3 text-slate-300";
      
      const modName = modTypeNames[type] || `Mod ${type}`;
      const level = modData.current === 0 ? "Stock" : `Level ${modData.current}`;
      const statusText = `${level} (Stock - Level ${modData.levels})`;
      
      li.innerHTML = `
        <span class="w-1.5 h-1.5 rounded-full bg-slate-400"></span>
        <span class="text-sm font-medium">${modName}: <span class="text-white font-semibold">${statusText}</span></span>
      `;
      upgradeList.appendChild(li);
    });
  }
};

reportBtn.addEventListener("click", () => {
  fetch(`https://${GetParentResourceName()}/reportToDiscord`, {
    method: "POST",
    body: JSON.stringify({}),
  }).then(() => {
    if (window.ReportCallback) {
      window.ReportCallback({ success: true });
    }
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