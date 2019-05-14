package lt.taurosevicius.vaultexample;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;

import static java.util.Objects.requireNonNull;

class PostgresqlFacade {
    private final String string;
    private String username;
    private String password;

    PostgresqlFacade(String url) {
        this.string = url;
    }

    PostgresqlFacade setCredentials(String username, String password) {
        this.username = username;
        this.password = password;
        return this;
    }


    String getPostgreSqlUser() throws SQLException {
        try (Connection con = DriverManager.getConnection(string, requireNonNull(username), requireNonNull(password));
             ResultSet rs = con
                     .createStatement()
                     .executeQuery("SELECT user")) {
            rs.next();
            return rs.getString(1);
        }
    }
}
