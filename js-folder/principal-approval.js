'use strict';

(function () {
  var page = document.body;
  var csrfToken = page.dataset.csrfToken;
  var requestsElement = document.getElementById('principalRequests');
  var detailDialog = document.getElementById('principalDetails');
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
    document.getElementById('principalDetailFields').appendChild(wrapper);
  }

  function openDetails(item) {
    selectedRequest = item;
    document.getElementById('principalDetailTitle').textContent = item.title;
    var badge = document.getElementById('principalDetailStatus');
    badge.className = 'status-badge ' + item.status;
    badge.textContent = statusLabel(item.status);
    var fields = document.getElementById('principalDetailFields');
    fields.replaceChildren();
    addDetail('Requester', item.requester_name + ' · ' + item.requester_role);
    addDetail('Email', item.requester_email);
    addDetail('Audience', item.audience + (item.audience_details ? ' · ' + item.audience_details : ''));
    addDetail('Submitted', displayDate(item.submitted_at));
    addDetail('Forwarded by OSSA', displayDate(item.principal_approval_requested_at));
    if (item.principal_decision_at) addDetail('Decision date', displayDate(item.principal_decision_at));
    document.getElementById('principalDetailMessage').textContent = item.message;
    var actions = document.getElementById('principalDetailActions');
    actions.replaceChildren();
    var closeButton = document.createElement('button');
    closeButton.className = 'btn ghost';
    closeButton.type = 'button';
    closeButton.textContent = 'Close';
    closeButton.dataset.closePrincipal = '';
    closeButton.addEventListener('click', function () { detailDialog.close(); });
    actions.appendChild(closeButton);
    if (item.status === 'for_principal_approval' && item.principal_decision === null) {
      ['approved', 'denied'].forEach(function (decision) {
        var button = document.createElement('button');
        button.className = decision === 'approved' ? 'btn green' : 'btn ghost';
        button.type = 'button';
        button.textContent = decision === 'approved' ? 'Approve' : 'Deny';
        button.dataset.principalDecision = decision;
        button.addEventListener('click', decide);
        actions.appendChild(button);
      });
    }
    detailDialog.showModal();
  }

  async function decide(event) {
    var button = event.currentTarget;
    var decision = button.dataset.principalDecision;
    if (!selectedRequest || !window.confirm('Are you sure you want to ' + decision + ' this request?')) return;
    var buttons = Array.from(document.querySelectorAll('[data-principal-decision]'));
    buttons.forEach(function (item) { item.disabled = true; });
    var data = new FormData();
    data.set('csrf_token', csrfToken);
    data.set('action', 'principal_decision');
    data.set('request_id', selectedRequest.id);
    data.set('decision', decision);
    try {
      await requestJson('../php-connections/request-management.php', {method:'POST', body:data});
      detailDialog.close();
      await refreshRequests();
    } catch (error) {
      window.alert(error.message);
      buttons.forEach(function (item) { item.disabled = false; });
    }
  }

  async function refreshRequests() {
    requestsElement.innerHTML = '<div class="empty box"><b>Loading forwarded requests</b>Checking the shared request records.</div>';
    try {
      var result = await requestJson('../php-connections/request-management.php?action=principal_list');
      requestsElement.replaceChildren();
      if (!result.requests.length) {
        requestsElement.innerHTML = '<div class="empty box"><b>No forwarded requests</b>Requests sent by the OSSA Admin for approval will appear here.</div>';
        return;
      }
      result.requests.forEach(function (item) {
        var card = document.createElement('article');
        card.className = 'panel request-card';
        card.innerHTML = '<div><span class="status-badge ' + escapeHtml(item.status) + '">' + escapeHtml(statusLabel(item.status)) + '</span>' +
          '<h3>' + escapeHtml(item.title) + '</h3><div class="request-card-meta"><span>' + escapeHtml(item.requester_name) + '</span><span class="role-badge">' + escapeHtml(item.requester_role) + '</span><span>' + escapeHtml(item.audience + (item.audience_details ? ' · ' + item.audience_details : '')) + '</span><span>' + escapeHtml(displayDate(item.submitted_at)) + '</span></div></div>' +
          '<div class="request-card-actions"><button class="btn ghost sm" type="button">View Details</button></div>';
        card.querySelector('button').addEventListener('click', function () { openDetails(item); });
        requestsElement.appendChild(card);
      });
    } catch (error) {
      requestsElement.innerHTML = '<div class="empty box" role="alert"><b>Forwarded requests could not be loaded</b>' + escapeHtml(error.message) + '</div>';
    }
  }

  document.getElementById('refreshApprovals').addEventListener('click', refreshRequests);
  document.addEventListener('click', function (event) {
    if (event.target.closest('[data-close-principal]')) detailDialog.close();
  });
  detailDialog.addEventListener('click', function (event) { if (event.target === detailDialog) detailDialog.close(); });
  refreshRequests();
})();
