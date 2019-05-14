package lt.taurosevicius.vaultexample;

import java.sql.SQLException;

public class ProductionRunner {
    public static void main(String[] args) throws InterruptedException {
        var vault = new VaultFacade();
        var postgresCredentials = vault.getPostgresCredentials();
        var postgres = new PostgresqlFacade("jdbc:postgresql://192.168.2.25:5432/mydb")
                .setCredentials(postgresCredentials.getData().get("username"), postgresCredentials.getData().get("password"));

        printPostgresUsername(postgres, "After getting credentials");

        vault.renewLease(postgresCredentials, 1);
        printPostgresUsername(postgres, "After setting renewal for 1 second");

        Thread.sleep(3000);
        printPostgresUsername(postgres, "After lease is expired");

        var newCredentials = vault.getPostgresCredentials();
        postgres = postgres.setCredentials(newCredentials.getData().get("username"), newCredentials.getData().get("password"));
        printPostgresUsername(postgres, "With a new lease");
    }

    private static void printPostgresUsername(PostgresqlFacade postgres, String info) {
        try {
            System.out.println(String.format("%-40s*** current postgreSQL username is [%s]", info, postgres.getPostgreSqlUser()));
        } catch (SQLException e) {
            System.out.println(String.format("%-40s*** Unable to get postgreSQL version: [%s]", info, e.getMessage()));
        }
        System.out.println("\n");
    }
}
