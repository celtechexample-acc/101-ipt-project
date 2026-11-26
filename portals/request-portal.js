'use strict';

(function () {
  var page = document.body;
  var role = page.dataset.portalRole;
  var session;
  try { session = JSON.parse(sessionStorage.getItem('celtechRequestDemoSession') || 'null'); }
  catch (_) { session = null; }
  if (!session || session.role !== role || !session.email || !session.name) {
    window.location.replace('teacher-officer-login.php');
    return;
  }

  var csrfToken = page.dataset.csrfToken;
  var requesterName = document.getElementById('requesterName');
  var form = document.getElementById('requestForm');
  var audience = document.getElementById('requestAudience');
  var detailField = document.getElementById('audienceDetailField');
  var detailInput = document.getElementById('audienceDetails');
  var detailLabel = document.getElementById('audienceDetailLabel');
  var statusMessage = document.getElementById('requestStatus');
  var requestList = document.getElementById('myRequests');
  var detailDialog = document.getElementById('requestDetails');
  var busy = false;
  var submissionKey = newKey();
  var detailLabels = {
    'Specific Batch':'Batch details',
    'Specific Course':'Course details',
    'Specific Year Level':'Year level details',
    'Specific Section':'Section details',
    Other:'Specify the audience'
  };

  requesterName.value = session.name;
  document.getElementById('requesterHeader').textContent = session.name;
  document.getElementById('requesterAvatar').textContent = session.name.split(/\s+/).map(function (part) { return part.charAt(0); }).slice(0, 2).join('').toUpperCase();
  document.querySelector('[data-demo-logout]').addEventListener('click', function () {
    sessionStorage.removeItem('celtechRequestDemoSession');
    window.location.replace('teacher-officer-login.php');
  });

  function newKey() {
    var bytes = new Uint8Array(16);
    if (window.crypto && window.crypto.getRandomValues) window.crypto.getRandomValues(bytes);
    else for (var index = 0; index < bytes.length; index++) bytes[index] = Math.floor(Math.random() * 256);
    return Array.prototype.map.call(bytes, function (byte) { return byte.toString(16).padStart(2, '0'); }).join('');
  }

  function escapeHtml(value) {
    return String(value == null ? '' : value).replace(/[&<>"']/g, function (char) {
      return {'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[char];
    });
  }

  function statusLabel(value) {
    return ({pending:'Pending', for_principal_approval:'For Principal Approval', approved:'Approved', denied:'Denied'})[value] || value;
  }

  function displayDate(value) {
    var parsed = new Date(String(value).replace(' ', 'T') + 'Z');
    return Number.isNaN(parsed.getTime()) ? value : parsed.toLocaleString();
  }

  function showMessage(text, isError) {
    statusMessage.textContent = text;
    statusMessage.classList.toggle('is-error', Boolean(isError));
    statusMessage.hidden = false;
  }

  async function requestJson(url, options) {
    var response = await fetch(url, Object.assign({credentials:'same-origin', headers:{Accept:'application/json'}}, options || {}));
    var result;
    try { result = await response.json(); }
    catch (_) { throw new Error('The server returned an invalid response. Please try again.'); }
    if (!response.ok || !result.ok) throw new Error(result.message || 'The request could not be completed.');
    return result;
  }

  function updateAudienceDetails() {
    var needsDetails = Object.prototype.hasOwnProperty.call(detailLabels, audience.value);
    detailField.hidden = !needsDetails;
    detailInput.required = needsDetails;
    detailLabel.textContent = detailLabels[audience.value] || 'Audience details';
    detailInput.placeholder = needsDetails ? 'Enter the intended audience details' : '';
    if (!needsDetails) detailInput.value = '';
  }

  function addDetail(label, value) {
    var term = document.createElement('dt');
    var description = document.createElement('dd');
    term.textContent = label;
    description.textContent = value || '—';
    var wrapper = document.createElement('div');
    wrapper.append(term, description);
    document.getElementById('requestDetailFields').appendChild(wrapper);
  }

  function openDetails(item) {
    document.getElementById('requestDetailTitle').textContent = item.title;
    var badge = document.getElementById('requestDetailStatus');
    badge.className = 'status-badge ' + item.status;
    badge.textContent = statusLabel(item.status);
    var fields = document.getElementById('requestDetailFields');
    fields.replaceChildren();
    addDetail('Requester', item.requester_name + ' · ' + item.requester_role);
    addDetail('Audience', item.audience + (item.audience_details ? ' · ' + item.audience_details : ''));
    addDetail('Submitted', displayDate(item.submitted_at));
    document.getElementById('requestDetailMessage').textContent = item.message;
    detailDialog.showModal();
  }

  function renderRequests(items) {
    requestList.replaceChildren();
    if (!items.length) {
      requestList.innerHTML = '<div class="empty box"><b>No requests yet</b>Submitted requests and their current status will appear here.</div>';
      return;
    }
    items.forEach(function (item) {
      var card = document.createElement('article');
      card.className = 'panel request-card';
      card.innerHTML = '<div><span class="status-badge ' + escapeHtml(item.status) + '">' + escapeHtml(statusLabel(item.status)) + '</span>' +
        '<h3>' + escapeHtml(item.title) + '</h3><div class="request-card-meta"><span>' + escapeHtml(item.audience + (item.audience_details ? ' · ' + item.audience_details : '')) + '</span><span>' + escapeHtml(displayDate(item.submitted_at)) + '</span></div></div>' +
        '<div class="request-card-actions"><button class="btn ghost sm" type="button" data-view-request="' + escapeHtml(item.id) + '">View Details</button></div>';
      card.querySelector('[data-view-request]').addEventListener('click', function () { openDetails(item); });
      requestList.appendChild(card);
    });
  }

  async function refreshRequests() {
    requestList.innerHTML = '<div class="empty box"><b>Loading requests</b>Checking the shared request records.</div>';
    try {
      var params = new URLSearchParams({action:'mine', email:session.email, role:session.role});
      var result = await requestJson('../php-connections/request-management.php?' + params.toString());
      renderRequests(result.requests);
    } catch (error) {
      requestList.innerHTML = '<div class="empty box" role="alert"><b>Requests could not be loaded</b>' + escapeHtml(error.message) + '</div>';
    }
  }

  audience.addEventListener('change', updateAudienceDetails);
  document.getElementById('refreshRequests').addEventListener('click', refreshRequests);
  document.querySelectorAll('[data-close-detail]').forEach(function (button) { button.addEventListener('click', function () { detailDialog.close(); }); });
  detailDialog.addEventListener('click', function (event) { if (event.target === detailDialog) detailDialog.close(); });

  form.addEventListener('submit', async function (event) {
    event.preventDefault();
    if (busy || !form.reportValidity()) return;
    busy = true;
    var submit = document.getElementById('submitRequest');
    submit.disabled = true;
    submit.textContent = 'Submitting...';
    statusMessage.hidden = true;
    var data = new FormData(form);
    data.set('action', 'create');
    data.set('requester_email', session.email);
    data.set('requester_role', session.role);
    data.set('idempotency_key', submissionKey);
    try {
      var result = await requestJson('../php-connections/request-management.php', {method:'POST', body:data});
      showMessage(result.duplicate ? 'This request was already received. Its saved status is shown below.' : 'Request submitted successfully. Current status: Pending.', false);
      form.reset();
      requesterName.value = session.name;
      submissionKey = newKey();
      updateAudienceDetails();
      await refreshRequests();
    } catch (error) {
      showMessage(error.message || 'The request could not be submitted. Please try again.', true);
    } finally {
      busy = false;
      submit.disabled = false;
      submit.textContent = 'Submit Request';
    }
  });

  updateAudienceDetails();
  refreshRequests();
})();
