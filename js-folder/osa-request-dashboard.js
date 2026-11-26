'use strict';

(function () {
  var csrfToken = document.querySelector('meta[name="csrf-token"]').content;
  var requestList = document.getElementById('adminRequests');
  var requestDialog = document.getElementById('adminRequestDetails');
  var requestStatus = document.getElementById('requestPageStatus');
  var activeRole = 'All';
  var activeStatus = 'All';
  var currentRequests = [];
  var selectedRequest = null;

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

  async function requestJson(url, options) {
    var response = await fetch(url, Object.assign({credentials:'same-origin', headers:{Accept:'application/json'}}, options || {}));
    var result;
    try { result = await response.json(); }
    catch (_) { throw new Error('The server returned an invalid response. Please try again.'); }
    if (!response.ok || !result.ok) throw new Error(result.message || 'The request could not be completed.');
    return result;
  }

  function addDetail(label, value) {
    var wrapper = document.createElement('div');
    var term = document.createElement('dt');
    var description = document.createElement('dd');
    term.textContent = label;
    description.textContent = value || '—';
    wrapper.append(term, description);
    document.getElementById('adminRequestDetailFields').appendChild(wrapper);
  }

  function openDetails(item) {
    selectedRequest = item;
    document.getElementById('adminRequestDetailTitle').textContent = item.title;
    var badge = document.getElementById('adminRequestDetailStatus');
    badge.className = 'status-badge ' + item.status;
    badge.textContent = statusLabel(item.status);
    var fields = document.getElementById('adminRequestDetailFields');
    fields.replaceChildren();
    addDetail('Requester', item.requester_name + ' · ' + item.requester_role);
    addDetail('Email', item.requester_email);
    addDetail('Audience', item.audience + (item.audience_details ? ' · ' + item.audience_details : ''));
    addDetail('Submitted', displayDate(item.submitted_at));
    if (item.principal_approval_requested_at) addDetail('Forwarded to Principal', displayDate(item.principal_approval_requested_at));
    if (item.principal_decision_at) addDetail('Principal decision date', displayDate(item.principal_decision_at));
    document.getElementById('adminRequestDetailMessage').textContent = item.message;
    var actions = document.getElementById('adminRequestDetailActions');
    actions.replaceChildren();
    var closeButton = document.createElement('button');
    closeButton.type = 'button';
    closeButton.className = 'btn ghost';
    closeButton.textContent = 'Close';
    closeButton.dataset.closeAdminDetail = '';
    closeButton.addEventListener('click', function () { requestDialog.close(); });
    actions.appendChild(closeButton);
    if (item.status === 'pending') {
      var forwardButton = document.createElement('button');
      forwardButton.type = 'button';
      forwardButton.className = 'btn green';
      forwardButton.textContent = 'Request Principal Approval';
      forwardButton.dataset.forwardRequest = '';
      forwardButton.addEventListener('click', forwardSelectedRequest);
      actions.appendChild(forwardButton);
    }
    requestDialog.showModal();
  }

  function renderRequests() {
    var visible = currentRequests.filter(function (item) { return activeStatus === 'All' || item.status === activeStatus; });
    requestList.replaceChildren();
    if (!visible.length) {
      requestList.innerHTML = '<div class="empty box"><b>No matching requests</b>Requests matching the selected filters will appear here.</div>';
      return;
    }
    visible.forEach(function (item) {
      var card = document.createElement('article');
      card.className = 'panel request-card';
      card.innerHTML = '<div><span class="status-badge ' + escapeHtml(item.status) + '">' + escapeHtml(statusLabel(item.status)) + '</span> <span class="role-badge">' + escapeHtml(item.requester_role) + '</span>' +
        '<h3>' + escapeHtml(item.title) + '</h3><div class="request-card-meta"><span>' + escapeHtml(item.requester_name) + '</span><span>' + escapeHtml(item.audience + (item.audience_details ? ' · ' + item.audience_details : '')) + '</span><span>' + escapeHtml(displayDate(item.submitted_at)) + '</span></div></div>' +
        '<div class="request-card-actions"><button class="btn ghost sm" type="button">View Details</button>' +
        (item.status === 'pending' ? '<button class="btn green sm" type="button" data-forward-request>Request Principal Approval</button>' : '') + '</div>';
      card.querySelector('.btn.ghost').addEventListener('click', function () { openDetails(item); });
      var forwardButton = card.querySelector('[data-forward-request]');
      if (forwardButton) forwardButton.addEventListener('click', function () { forwardRequest(item); });
      requestList.appendChild(card);
    });
  }

  function renderCounts(counts) {
    var totalPending = Number(counts.pending || 0) + Number(counts.for_principal_approval || 0);
    document.getElementById('requestNavCount').textContent = totalPending ? String(totalPending) : '';
    document.getElementById('requestPendingCount').textContent = String(counts.pending || 0);
    document.getElementById('requestPrincipalCount').textContent = String(counts.for_principal_approval || 0);
    document.getElementById('requestApprovedCount').textContent = String(counts.approved || 0);
    document.getElementById('requestDeniedCount').textContent = String(counts.denied || 0);
  }

  async function refreshRequests() {
    requestList.innerHTML = '<div class="empty box"><b>Loading requests</b>Reading request records from the shared database.</div>';
    requestStatus.hidden = true;
    try {
      var result = await requestJson('../php-connections/request-management.php?action=admin_list&role=' + encodeURIComponent(activeRole));
      currentRequests = result.requests;
      renderCounts(result.counts);
      renderRequests();
    } catch (error) {
      requestList.innerHTML = '<div class="empty box" role="alert"><b>Requests could not be loaded</b>' + escapeHtml(error.message) + '</div>';
      requestStatus.textContent = error.message;
      requestStatus.classList.add('is-error');
      requestStatus.hidden = false;
    }
  }

  async function forwardRequest(item) {
    if (!item || item.status !== 'pending') return;
    var data = new FormData();
    data.set('csrf_token', csrfToken);
    data.set('action', 'forward_principal');
    data.set('request_id', item.id);
    try {
      await requestJson('../php-connections/request-management.php', {method:'POST', body:data});
      requestStatus.textContent = 'Request forwarded to the Principal for approval.';
      requestStatus.classList.remove('is-error');
      requestStatus.hidden = false;
      if (requestDialog.open) requestDialog.close();
      await refreshRequests();
    } catch (error) {
      requestStatus.textContent = error.message;
      requestStatus.classList.add('is-error');
      requestStatus.hidden = false;
      await refreshRequests();
    }
  }

  async function forwardSelectedRequest() {
    var button = document.querySelector('#adminRequestDetailActions [data-forward-request]');
    if (!button || !selectedRequest) return;
    button.disabled = true;
    await forwardRequest(selectedRequest);
  }

  document.querySelectorAll('[data-request-role]').forEach(function (button) {
    button.addEventListener('click', function () {
      activeRole = button.dataset.requestRole;
      document.querySelectorAll('[data-request-role]').forEach(function (tab) {
        tab.setAttribute('aria-pressed', String(tab === button));
      });
      refreshRequests();
    });
  });
  document.getElementById('requestStatusFilter').addEventListener('change', function () {
    activeStatus = this.value;
    renderRequests();
  });
  document.getElementById('refreshAdminRequests').addEventListener('click', refreshRequests);
  document.querySelectorAll('[data-request-status]').forEach(function (card) {
    card.addEventListener('click', function () {
      activeRole = 'All';
      activeStatus = card.dataset.requestStatus;
      document.querySelectorAll('[data-request-role]').forEach(function (tab) {
        tab.setAttribute('aria-pressed', String(tab.dataset.requestRole === 'All'));
      });
      document.getElementById('requestStatusFilter').value = activeStatus;
      window.location.hash = '#requests';
      refreshRequests();
    });
  });
  document.addEventListener('click', function (event) {
    if (event.target.closest('[data-close-admin-detail]')) requestDialog.close();
  });
  requestDialog.addEventListener('click', function (event) { if (event.target === requestDialog) requestDialog.close(); });
  refreshRequests();
})();
