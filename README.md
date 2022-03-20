# Hetzner-VPN

## Setting up environment

Build image
```fish
docker build --rm --file Dockerfile --tag ansible:2.10.15-hetzner-vpn .
```

## Write secrets to encrypted file

Create Vault password file named `.vault_password` and add password into it

Create encrypted file
```fish
docker run --rm -ti \
    --volume=(pwd):/etc/ansible \
    ansible:2.10.15-hetzner-vpn \
        ansible-vault create host_vars/localhost/vault.yml
```

1. Generate API token to access Hetzner
   - <Project_name> -> Security -> API TOKENS
   - Permissions: Read & Write
   - Write token to variable `vault_hcloud_token`

2. Write domain to variable `vault_domain`, e.g. `domain.com`

3. Write username and comment for technical account to variables:
   - `vault_name`
   - `vault_comment`

4. Write custom SSH port to variable `vault_ssh_port`

5. Write creadentials to access 1Password to variables:
   - `vault_1password_device_id` - can be found in ~/.op/config
   - `vault_1password_master_password`, e.g. `'S0me P@ssword'`
   - `vault_1password_subdomain`, e.g. `my`
   - `vault_1password_email_address`
   - `vault_1password_secret_key`
   - `vault_1password_vault_name` - vault to write secrets (will be created if doesn't exist)

6. Generate token to access GitHub
   - <GitHub_profile> -> Settings -> Developer settings -> Personal access tokens
   - Scopes: public_repo
   - Write username to variable `vault_github_username`
   - Write token to variable `vault_github_password`

7. Generate API token to access Cloudflare
   - My Profile -> API Tokens -> API Tokens
   - Permissions:
     - Zone Zone Read
     - Zone DNS Edit
   - Zone Resources:
     - Include -> Specific zone -> domain from step 2, e.g. `domain.com`
   - Write token to variable `vault_cloudflare_api_token`

8. Write e-mail address for Let's Encrypt to variable `vault_letsencrypt_email`

To edit encrypted file use command
```fish
docker run --rm -ti \
    --volume=(pwd):/etc/ansible \
    ansible:2.10.15-hetzner-vpn \
        ansible-vault edit host_vars/localhost/vault.yml
```

## Launch installation

Run playbook to install kubernetes cluster
```fish
docker run --rm -t \
    --volume=(pwd):/etc/ansible \
    ansible:2.10.15-hetzner-vpn \
        ansible-playbook site.yml
```

Run playbook to delete all resources
```fish
docker run --rm -t \
    --volume=(pwd):/etc/ansible \
    ansible:2.10.15-hetzner-vpn \
        ansible-playbook site.yml --tags "destroy"
```
