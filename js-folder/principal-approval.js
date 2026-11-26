'use strict';

(function () {
  var page = document.body;
  var csrfToken = page.dataset.csrfToken;
  var requestsElement = document.getElementById('principalRequests');
  var detailDialog = document.getElementById('principalDetails');
  var selectedRequest = null;
  var selectedAnnouncementReview = null;

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

  function audienceLabel(raw) {
    try {
      var audience = JSON.parse(raw);
      if (audience.mode === 'all_active') return 'All active students';
      if (audience.mode === 'selective') return (audience.student_ids || []).length + ' selected students';
    } catch (_) {}
    return 'Recipient selection saved';
  }

  function openAnnouncementReview(review) {
    selectedAnnouncementReview = review;
    document.getElementById('principalDetailTitle').textContent = review.title;
    var badge = document.getElementById('principalDetailStatus');
    badge.className = 'status-badge ' + review.review_status;
    badge.textContent = review.review_status === 'approved'
      ? 'Approved – Ready to Publish'
      : review.review_status === 'changes_requested'
        ? 'Changes Requested'
        : 'Pending Principal Review';
    var fields = document.getElementById('principalDetailFields');
    fields.replaceChildren();
    addDetail('Submitting OSA Admin', review.submitted_by_name);
    addDetail('Publish date', review.publish_date || '—');
    addDetail('Audience', audienceLabel(review.audience_json));
    addDetail('Selected recipients', String((function () {
      try {
        var audience = JSON.parse(review.audience_json);
        return audience.mode === 'all_active' ? 'All active students' : (audience.student_ids || []).length;
      } catch (_) { return '—'; }
    })()));
    addDetail('Submitted', displayDate(review.submitted_at));
    if (review.reviewed_at) addDetail('Reviewed', displayDate(review.reviewed_at));
    document.getElementById('principalDetailMessage').textContent = review.details;
    var actions = document.getElementById('principalDetailActions');
    actions.replaceChildren();
    var closeButton = document.createElement('button');
    closeButton.className = 'btn ghost';
    closeButton.type = 'button';
    closeButton.textContent = 'Close';
    closeButton.addEventListener('click', function () { detailDialog.close(); });
    actions.appendChild(closeButton);
    if (review.review_status === 'pending') {
      var note = document.createElement('textarea');
      note.id = 'principalReviewNote';
      note.placeholder = 'Explain the changes or corrections required before this announcement can be approved.';
      note.setAttribute('aria-label', 'Principal Review Notes');
      note.style.cssText = 'width:100%;min-height:90px;margin:10px 0;';
      document.getElementById('principalDetailMessage').appendChild(note);
      var changesButton = document.createElement('button');
      changesButton.className = 'btn ghost';
      changesButton.type = 'button';
      changesButton.textContent = 'Request Changes';
      changesButton.addEventListener('click', function () { decideAnnouncement('changes_requested', note.value); });
      var approveButton = document.createElement('button');
      approveButton.className = 'btn green';
      approveButton.type = 'button';
      approveButton.textContent = 'Approve';
      approveButton.addEventListener('click', function () { decideAnnouncement('approved', note.value); });
      actions.appendChild(changesButton);
      actions.appendChild(approveButton);
    }
    detailDialog.showModal();
  }

  async function decideAnnouncement(decision, note) {
    if (!selectedAnnouncementReview) return;
    if (decision === 'changes_requested' && !note.trim()) {
      window.alert('Principal Review Notes are required when requesting changes.');
      return;
    }
    var data = new FormData();
    data.set('csrf_token', csrfToken);
    data.set('action', 'principal_decision');
    data.set('review_id', String(selectedAnnouncementReview.review_id));
    data.set('decision', decision);
    data.set('review_note', note.trim());
    try {
      await requestJson('../php-connections/announcement-management.php', {method:'POST', body:data});
      detailDialog.close();
      await refreshAnnouncementReviews();
    } catch (error) {
      window.alert(error.message);
    }
  }

  async function refreshAnnouncementReviews() {
    var element = document.getElementById('principalAnnouncementReviews');
    element.innerHTML = '<div class="empty box"><b>Loading announcement reviews</b>Checking submitted announcement plans.</div>';
    try {
      var result = await requestJson('../php-connections/announcement-management.php?action=principal_list');
      element.replaceChildren();
      if (!result.reviews.length) {
        element.innerHTML = '<div class="empty box"><b>No announcement reviews</b>Plans submitted by the OSSA admin will appear here.</div>';
        return;
      }
      result.reviews.forEach(function (review) {
        var card = document.createElement('article');
        card.className = 'panel request-card';
        var label = review.review_status === 'approved'
          ? 'Approved – Ready to Publish'
          : review.review_status === 'changes_requested'
            ? 'Changes Requested'
            : 'Pending Principal Review';
        card.innerHTML = '<div><span class="status-badge ' + escapeHtml(review.review_status) + '">' + escapeHtml(label) + '</span>' +
          '<h3>' + escapeHtml(review.title) + '</h3><div class="request-card-meta"><span>' +
          escapeHtml(review.submitted_by_name) + '</span><span>' + escapeHtml(audienceLabel(review.audience_json)) +
          '</span><span>Publish date: ' + escapeHtml(review.publish_date || '—') + '</span><span>' +
          escapeHtml(displayDate(review.submitted_at)) + '</span></div>' +
          (review.review_note ? '<p class="hint">Principal Review Notes: ' + escapeHtml(review.review_note) + '</p>' : '') +
          '</div><div class="request-card-actions"><button class="btn ghost sm" type="button">Review Plan</button></div>';
        card.querySelector('button').addEventListener('click', function () { openAnnouncementReview(review); });
        element.appendChild(card);
      });
    } catch (error) {
      element.innerHTML = '<div class="empty box" role="alert"><b>Announcement reviews could not be loaded</b>' + escapeHtml(error.message) + '</div>';
    }
  }

  document.getElementById('refreshApprovals').addEventListener('click', refreshRequests);
  document.getElementById('refreshAnnouncementReviews').addEventListener('click', refreshAnnouncementReviews);
  document.querySelectorAll('[data-go]').forEach(function (link) {
    link.addEventListener('click', function () {
      var target = link.getAttribute('href').slice(1);
      document.querySelectorAll('.view').forEach(function (view) { view.hidden = view.id !== 'v-' + target; });
      document.querySelectorAll('[data-go]').forEach(function (item) {
        item.setAttribute('aria-current', item === link ? 'page' : 'false');
      });
    });
  });
  document.addEventListener('click', function (event) {
    if (event.target.closest('[data-close-principal]')) detailDialog.close();
  });
  detailDialog.addEventListener('click', function (event) { if (event.target === detailDialog) detailDialog.close(); });
  refreshRequests();
  refreshAnnouncementReviews();
})();
