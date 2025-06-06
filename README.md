# kubeadm-install

Bu repoda bulunan scriptleri `chmod +x k8s-install.sh` ile çalıştırılabilir hale getirip,  
`sudo ./k8s-install.sh` komutuyla kubeadm kurulumu yapabilirsiniz.

---

## Worker Node'da Alınan Hata

Eğer aşağıdaki hatayı alırsanız:

couldn't get current server API group list: Get "http://localhost:8080/api?timeout=32s": dial tcp 127.0.0.1:8080: connect: connection refused
The connection to the server localhost:8080 was refused - did you specify the right host or port?


### Bu Hata Ne Anlama Geliyor?

`kubectl` komutu API server’a bağlanmaya çalışıyor ama bulamıyor.  
Bunun sebebi, `kubectl`'in `~/.kube/config` dosyasını bulamaması veya içeriğinin doğru olmamasıdır.  
Bu yüzden varsayılan olarak `localhost:8080` adresine gitmeye çalışıyor ve orada API server bulunamadığı için bağlantı reddediliyor.

---

## Çözüm

Master node’da aşağıdaki komutları çalıştırarak `admin.conf` dosyasını kullanıcı dizinine kopyalayıp, izinleri ayarlayın:
Ardından tekrar deneyin:
kubectl get nodes

```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

![image](https://github.com/user-attachments/assets/304f0f2f-1d7c-42ba-bf54-c575caa2e0d6)

