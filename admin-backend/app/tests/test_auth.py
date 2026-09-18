from __future__ import annotations


def test_admin_login_success(client):
    resp = client.post("/admin/auth/login", json={"email": "admin@kalyan.com", "password": "admin123"})
    assert resp.status_code == 200
    body = resp.json()
    assert body["user"]["role"] == "super_admin"
    assert body["token"]


def test_admin_login_wrong_password(client):
    resp = client.post("/admin/auth/login", json={"email": "admin@kalyan.com", "password": "wrong"})
    assert resp.status_code == 401


def test_admin_me_requires_token(client):
    resp = client.get("/admin/auth/me")
    assert resp.status_code == 401


def test_admin_me_with_token(client, auth_headers):
    resp = client.get("/admin/auth/me", headers=auth_headers)
    assert resp.status_code == 200
    assert resp.json()["email"] == "admin@kalyan.com"


def test_login_and_me_include_own_permissions(client, auth_headers):
    login = client.post("/admin/auth/login", json={"email": "admin@kalyan.com", "password": "admin123"})
    assert "admins.manage" in login.json()["user"]["permissions"]

    me = client.get("/admin/auth/me", headers=auth_headers)
    assert "admins.manage" in me.json()["permissions"]
    assert "results.correct" in me.json()["permissions"]


def test_admin_login_rate_limited_after_five_attempts(client):
    for _ in range(5):
        resp = client.post("/admin/auth/login", json={"email": "nope@kalyan.com", "password": "wrong"})
        assert resp.status_code == 401
    resp = client.post("/admin/auth/login", json={"email": "nope@kalyan.com", "password": "wrong"})
    assert resp.status_code == 429


def test_user_register_and_login(client):
    resp = client.post("/auth/register", json={"name": "New User", "phone": "9111111111", "password": "pass123"})
    assert resp.status_code == 201
    assert resp.json()["user"]["balance"] == 0

    resp = client.post("/auth/login", json={"phone": "9111111111", "password": "pass123"})
    assert resp.status_code == 200
    assert resp.json()["token"]


def test_user_token_rejected_on_admin_endpoints(client, user_headers):
    resp = client.get("/admin/users", headers=user_headers)
    assert resp.status_code == 401


def test_admin_token_rejected_on_user_endpoints(client, auth_headers):
    resp = client.get("/auth/me", headers=auth_headers)
    assert resp.status_code == 401
