package lt.taurosevicius.vaultexample;

import com.bettercloud.vault.SslConfig;
import com.bettercloud.vault.Vault;
import com.bettercloud.vault.VaultConfig;
import com.bettercloud.vault.VaultException;
import com.bettercloud.vault.response.LogicalResponse;

class VaultFacade {
    private final Vault vault;

    VaultFacade() {
        try {
            VaultConfig vaultConfig = new VaultConfig()
                    .address("https://127.0.0.1:8200")               // Defaults to "VAULT_ADDR" environment variable
                    .engineVersion(1)
                    .openTimeout(5)                                 // Defaults to "VAULT_OPEN_TIMEOUT" environment variable
                    .readTimeout(30)
                    .sslConfig(new SslConfig().verify(false).build())
                    .build();
            vault = new Vault(vaultConfig);
        } catch (VaultException e) {
            throw new RuntimeException(e);
        }
    }

    LogicalResponse getPostgresCredentials() {
        try {
            return vault.logical().read("dbs/creds/mydb-user");
        } catch (VaultException e) {
            throw new RuntimeException(e);
        }
    }

    void renewLease(LogicalResponse lease, long period) {
        if (lease.getRenewable())
            try {
                vault.leases().renew(lease.getLeaseId(), period);
                return;
            } catch (VaultException e) {
                throw new RuntimeException(e);
            }
        throw new RuntimeException(String.format("Lease [%s] is not renewable", lease.getLeaseId()));
    }
}
