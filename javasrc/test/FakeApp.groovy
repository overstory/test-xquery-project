package test

import org.apache.http.HttpResponse
import org.apache.http.auth.AuthScope
import org.apache.http.auth.UsernamePasswordCredentials
import org.apache.http.client.CredentialsProvider
import org.apache.http.client.HttpClient
import org.apache.http.client.methods.HttpGet
import org.apache.http.impl.client.BasicCredentialsProvider
import org.apache.http.impl.client.HttpClientBuilder

/**
 * Created by IntelliJ IDEA.
 * User: ron
 * Date: 6/11/17
 * Time: 9:37 PM
 */
class FakeApp
{
	private static String uri = new URI ('http://192.168.99.100:9003/examples/example8.xqy?foobar=barfoo&m:nsvar=blurble&z:exter=2015-03-22')
	private static String user = 'admin'
	private static String password = 'admin'

	static void main (String[] args)
	{
		CredentialsProvider provider = new BasicCredentialsProvider()
		provider.setCredentials (AuthScope.ANY, new UsernamePasswordCredentials (user, password))
		HttpClient client = HttpClientBuilder.create().setDefaultCredentialsProvider (provider).build()
		HttpResponse response = client.execute (new HttpGet (uri))

		println response.getEntity().getContent().text
	}
}
