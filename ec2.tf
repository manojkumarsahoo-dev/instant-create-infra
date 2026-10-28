# Public EC2 test server (one instance)
resource "aws_instance" "public_1" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public_1.id
  vpc_security_group_ids      = [aws_security_group.public_sg.id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ec2_ssm_profile.name

  user_data = <<-EOF
    #!/bin/bash
    dnf install -y python3
    cat > /home/ec2-user/server.py <<'PYEOF'
    from http.server import BaseHTTPRequestHandler, HTTPServer

    class Handler(BaseHTTPRequestHandler):
        def do_GET(self):
            body = b"Public EC2 server is running"
            self.send_response(200)
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            self.wfile.write(body)

    HTTPServer(("0.0.0.0", 80), Handler).serve_forever()
    PYEOF
    chown ec2-user:ec2-user /home/ec2-user/server.py
    cat > /etc/systemd/system/public-server.service <<'SERVICEEOF'
    [Unit]
    Description=Public test web server
    After=network.target

    [Service]
    User=root
    ExecStart=/usr/bin/python3 /home/ec2-user/server.py
    Restart=always

    [Install]
    WantedBy=multi-user.target
    SERVICEEOF
    systemctl daemon-reload
    systemctl enable --now public-server
  EOF

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-public-1"
    Tier = "Public"
  })

  depends_on = [aws_iam_role_policy_attachment.ssm_core]
}

# Backend EC2 (one instance, application listens on port 8080)
resource "aws_instance" "backend_1" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.backend_1.id
  vpc_security_group_ids = [aws_security_group.backend_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_ssm_profile.name

  user_data = <<-EOF
    #!/bin/bash
    dnf install -y python3
    cat > /home/ec2-user/backend.py <<'PYEOF'
    from http.server import BaseHTTPRequestHandler, HTTPServer

    class Handler(BaseHTTPRequestHandler):
        def do_GET(self):
            body = b"Backend EC2 server is running"
            self.send_response(200)
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            self.wfile.write(body)

    HTTPServer(("0.0.0.0", 8080), Handler).serve_forever()
    PYEOF
    chown ec2-user:ec2-user /home/ec2-user/backend.py
    cat > /etc/systemd/system/backend.service <<'SERVICEEOF'
    [Unit]
    Description=Backend test application
    After=network.target

    [Service]
    User=ec2-user
    ExecStart=/usr/bin/python3 /home/ec2-user/backend.py
    Restart=always

    [Install]
    WantedBy=multi-user.target
    SERVICEEOF
    systemctl daemon-reload
    systemctl enable --now backend
  EOF

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-backend-1"
    Tier = "Backend"
  })

  depends_on = [aws_iam_role_policy_attachment.ssm_core]
}

# Frontend EC2 (one instance, proxies /api to internal ALB)
resource "aws_instance" "frontend_1" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.frontend_1.id
  vpc_security_group_ids = [aws_security_group.frontend_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_ssm_profile.name

  user_data = <<-EOF
    #!/bin/bash
    dnf install -y python3
    cat > /home/ec2-user/frontend.py <<'PYEOF'
    from http.server import BaseHTTPRequestHandler, HTTPServer
    from urllib.request import urlopen

    BACKEND_URL = "http://${aws_lb.internal.dns_name}/"

    class Handler(BaseHTTPRequestHandler):
        def do_GET(self):
            if self.path.startswith("/api"):
                try:
                    with urlopen(BACKEND_URL, timeout=5) as response:
                        body = response.read()
                        status = response.status
                except Exception as error:
                    body = ("Backend request failed: " + str(error)).encode()
                    status = 502
            else:
                body = b"Frontend EC2 server is running. Use /api to test backend."
                status = 200

            self.send_response(status)
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            self.wfile.write(body)

    HTTPServer(("0.0.0.0", 80), Handler).serve_forever()
    PYEOF
    chown ec2-user:ec2-user /home/ec2-user/frontend.py
    cat > /etc/systemd/system/frontend.service <<'SERVICEEOF'
    [Unit]
    Description=Frontend test application
    After=network.target

    [Service]
    User=root
    ExecStart=/usr/bin/python3 /home/ec2-user/frontend.py
    Restart=always

    [Install]
    WantedBy=multi-user.target
    SERVICEEOF
    systemctl daemon-reload
    systemctl enable --now frontend
  EOF

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-frontend-1"
    Tier = "Frontend"
  })

  depends_on = [
    aws_iam_role_policy_attachment.ssm_core,
    aws_lb_listener.internal_http
  ]
}

# Database placeholder EC2 (no database software installed)
resource "aws_instance" "database_1" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.database_1.id
  vpc_security_group_ids = [aws_security_group.database_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_ssm_profile.name

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-database-1"
    Tier = "Database"
  })

  depends_on = [aws_iam_role_policy_attachment.ssm_core]
}

# Register the single instances with their target groups
resource "aws_lb_target_group_attachment" "frontend_1" {
  target_group_arn = aws_lb_target_group.frontend.arn
  target_id        = aws_instance.frontend_1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "backend_1" {
  target_group_arn = aws_lb_target_group.backend.arn
  target_id        = aws_instance.backend_1.id
  port             = 8080
}
