// Simple client-side demo logic using localStorage
const donorsKey = 'bbs_donors_v1';
const inventoryKey = 'bbs_inventory_v1';
const requestsKey = 'bbs_requests_v1';

function loadJSON(key, def){ try{return JSON.parse(localStorage.getItem(key))||def}catch(e){return def}}
function saveJSON(key, val){ localStorage.setItem(key, JSON.stringify(val)) }

let donors = loadJSON(donorsKey, []);
let inventory = loadJSON(inventoryKey, {});
let requests = loadJSON(requestsKey, []);

// ensure all blood groups present
const B_GROUPS = ['A+','A-','B+','B-','O+','O-','AB+','AB-'];
B_GROUPS.forEach(g=>{ if(inventory[g]==null) inventory[g]=0 });
saveJSON(inventoryKey, inventory);

// DOM helpers
const donorsTableBody = document.querySelector('#donors-table tbody');
const inventoryTableBody = document.querySelector('#inventory-table tbody');
const requestsTableBody = document.querySelector('#requests-table tbody');

function renderDonors(){ donorsTableBody.innerHTML = '';
  donors.forEach((d,idx)=>{
    const tr = document.createElement('tr');
    tr.innerHTML = `<td>${d.name}</td><td>${d.bgroup}</td><td>${d.age}</td><td>${d.phone||''}</td><td><button data-idx='${idx}' class='btn ghost small del-donor'>Delete</button></td>`;
    donorsTableBody.appendChild(tr);
  });
}

function renderInventory(){ inventoryTableBody.innerHTML='';
  B_GROUPS.forEach(g=>{
    const tr = document.createElement('tr');
    tr.innerHTML = `<td>${g}</td><td>${inventory[g]||0}</td><td><button data-group='${g}' class='btn ghost small use-unit'>Use 1</button></td>`;
    inventoryTableBody.appendChild(tr);
  })
}

function renderRequests(){ requestsTableBody.innerHTML='';
  requests.forEach(r=>{
    const tr=document.createElement('tr');
    tr.innerHTML = `<td>${r.patient}</td><td>${r.bgroup}</td><td>${r.units}</td><td>${r.status}</td>`;
    requestsTableBody.appendChild(tr);
  })
}

// Initial render
renderDonors(); renderInventory(); renderRequests();

// Donor form
const donorForm = document.getElementById('donor-form');
donorForm.addEventListener('submit', e=>{
  e.preventDefault();
  const d = {name:document.getElementById('d-name').value.trim(), age:parseInt(document.getElementById('d-age').value,10), gender:document.getElementById('d-gender').value, bgroup:document.getElementById('d-bgroup').value, phone:document.getElementById('d-phone').value, lastDonation:document.getElementById('d-last').value };
  if(!d.name||!d.age) return alert('Please provide name and age');
  if(d.age<16) return alert('Donor must be at least 16 years old');
  donors.push(d); saveJSON(donorsKey, donors); renderDonors(); donorForm.reset();
});

// Delete donor
document.addEventListener('click', e=>{
  if(e.target.classList.contains('del-donor')){
    const idx = parseInt(e.target.dataset.idx,10); donors.splice(idx,1); saveJSON(donorsKey, donors); renderDonors();
  }
  if(e.target.classList.contains('use-unit')){
    const g = e.target.dataset.group; if(inventory[g]>0){ inventory[g]-=1; saveJSON(inventoryKey, inventory); renderInventory(); alert('One unit used from '+g)} else { alert('No units available for '+g) }
  }
});

// Clear donors
document.getElementById('clear-donors').addEventListener('click', ()=>{ if(confirm('Delete all donors?')){ donors=[]; saveJSON(donorsKey, donors); renderDonors(); } });

// Inventory form
document.getElementById('inventory-form').addEventListener('submit', e=>{
  e.preventDefault(); const g=document.getElementById('i-bgroup').value; const u=parseInt(document.getElementById('i-units').value,10)||1; inventory[g]=(inventory[g]||0)+u; saveJSON(inventoryKey, inventory); renderInventory(); e.target.reset();
});

// Request form
document.getElementById('request-form').addEventListener('submit', e=>{
  e.preventDefault(); const patient=document.getElementById('r-name').value.trim(); const g=document.getElementById('r-bgroup').value; const u=parseInt(document.getElementById('r-units').value,10)||1; const phone=document.getElementById('r-phone').value.trim();
  if(!patient) return alert('Enter patient name');
  const status = (inventory[g]||0) >= u ? 'Fulfilled' : 'Pending';
  if(status==='Fulfilled') inventory[g]-=u; saveJSON(inventoryKey, inventory);
  const req = {patient, bgroup:g, units:u, phone, status, time: new Date().toISOString()};
  requests.unshift(req); saveJSON(requestsKey, requests); renderRequests(); renderInventory(); e.target.reset();
});

// small helper to reset demo data via console
window.resetDemo = ()=>{ if(confirm('Reset all demo data?')){ donors=[]; inventory={}; B_GROUPS.forEach(g=>inventory[g]=0); requests=[]; saveJSON(donorsKey,donors); saveJSON(inventoryKey,inventory); saveJSON(requestsKey,requests); renderDonors(); renderInventory(); renderRequests(); }}

