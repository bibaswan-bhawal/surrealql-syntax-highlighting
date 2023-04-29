DEFINE NAMESPACE abcum
DEFINE NS abcum;

DEFINE DATABASE app_vitalsense;
DEFINE DB app_vitalsense;

DEFINE LOGIN username 
  ON NAMESPACE 
  PASSWORD '123456';

DEFINE LOGIN username 
  ON NAMESPACE 
  PASSHASH '123456';

DEFINE LOGIN username 
  ON DATABASE 
  PASSWORD '123456';
DEFINE LOGIN username 
  ON DATABASE 
  PASSHASH '123456';


DEFINE TOKEN token_name
  ON NAMESPACE
  TYPE HS512
  VALUE "sNSYneezcr8kqphfOC6NwwraUHJCVAt0XjsRSNmssBaBRh3WyMa9TRfq8ST7fsU2H2kGiOpU4GbAF1bCiXmM1b3JGgleBzz7rsrz6VvYEM4q3CLkcO8CMBIlhwhzWmy8"
;

DEFINE TOKEN token_name
  -- Use this OAuth provider for database authorization
  ON DATABASE
  -- Specify the cryptographic signature algorithm used to sign the token
  TYPE HS512
  -- Specify the public key so we can verify the authenticity of the token
  VALUE "sNSYneezcr8kqphfOC6NwwraUHJCVAt0XjsRSNmssBaBRh3WyMa9TRfq8ST7fsU2H2kGiOpU4GbAF1bCiXmM1b3JGgleBzz7rsrz6VvYEM4q3CLkcO8CMBIlhwhzWmy8"
;

-- Set the name of the token
DEFINE TOKEN token_name
  ON SCOPE account
  TYPE HS512
  VALUE "sNSYneezcr8kqphfOC6NwwraUHJCVAt0XjsRSNmssBaBRh3WyMa9TRfq8ST7fsU2H2kGiOpU4GbAF1bCiXmM1b3JGgleBzz7rsrz6VvYEM4q3CLkcO8CMBIlhwhzWmy8"
;

DEFINE TOKEN token_name ON SCOPE account TYPE HS512 VALUE "bob"

DEFINE SCOPE account 
  SESSION 24h
	SIGNUP ( CREATE user SET email = $email, pass = crypto::argon2::generate($pass) )
	SIGNIN ( SELECT * FROM user WHERE email = $email AND crypto::argon2::compare(pass, $pass) )
;

DEFINE TABLE reading;
DEFINE TABLE reading DROP;
DEFINE TABLE user SCHEMAFULL;
DEFINE TABLE user SCHEMALESS;

DEFINE TABLE user DROP SCHEMAFULL;
DEFINE TABLE user DROP SCHEMALESS;

DEFINE TABLE temperatures_by_month AS 
  SELECT
    count() AS total,
		time::month(recorded_at) AS month,
		math::mean(temperature) AS average_temp
	FROM reading
  	WHERE city = 'London' 
	GROUP BY city
;

DEFINE TABLE post SCHEMALESS
	PERMISSIONS
		FOR select
			-- Published posts can be selected
			WHERE published = true
			-- A user can select all their own posts
			OR user = $auth.id
		FOR create, update
			-- A user can create or update their own posts
			WHERE user = $auth.id
		FOR delete
			-- A user can delete their own posts
			WHERE user = $auth.id
			-- Or an admin can delete any posts
			OR $auth.admin = true
;

DEFINE TABLE post SCHEMALESS AS 
  SELECT
    count() AS total,
		time::month(recorded_at) AS month,
		math::mean(temperature) AS average_temp
	FROM reading WHERE city = 'London' 
  GROUP BY city
  
  PERMISSIONS
		FOR select
			WHERE published = true OR user = $auth.id
		FOR create, update
			WHERE user = $auth.id
		FOR delete
			WHERE user = $auth.id OR $auth.admin = true
;
